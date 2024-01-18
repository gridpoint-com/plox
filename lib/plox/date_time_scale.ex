defmodule Plox.DateTimeScale do
  @moduledoc """
  A scale made of elixir `DateTime` or `NaiveDateTime` values

  This struct implements the `Plox.Scale` protocol.
  """
  require Logger

  defstruct [:first, :last]

  @type t :: %__MODULE__{}
  @type datetime :: DateTime.t() | NaiveDateTime.t()

  @doc """
  Creates a new `Plox.DateTimeScale` struct

  Accepts 2 elixir `DateTime` or `NaiveDateTime` structs as `first` and `last`.
  Negative ranges are not currently supported.
  """
  @spec new(first :: datetime(), last :: datetime()) :: t()
  def new(first, last)

  def new(%date_time_module{} = first, %date_time_module{} = last)
      when date_time_module in [DateTime, NaiveDateTime] do
    if date_time_module.diff(last, first) <= 0 do
      raise ArgumentError,
        message:
          "Invalid DateTimeScale: The range must be at least 1 second long and `first` must come before `last`."
    end

    %__MODULE__{first: first, last: last}
  end

  def new(_first, _last) do
    raise ArgumentError,
      message: "Invalid DateTimeScale: First and last must be DateTime or NaiveDateTime structs."
  end

  defimpl Plox.Scale do
    def values(%{first: %DateTime{time_zone: tz}} = scale, %{step: {step_days, :day}})
        when tz != "Etc/UTC" do
      Stream.unfold(scale.first, fn current_dt ->
        if DateTime.compare(current_dt, scale.last) == :gt do
          nil
        else
          {current_dt, shift_days(current_dt, step_days)}
        end
      end)
      |> Enum.to_list()
    end

    def values(scale, opts) do
      %{first: %date_time_module{}} = scale

      step_seconds =
        case Map.get(opts, :step, {60, :second}) do
          seconds when is_integer(seconds) -> seconds
          {seconds, :second} -> seconds
          {minutes, :minute} -> minutes * 60
          {hours, :hour} -> hours * 3600
          {days, :day} -> days * 86_400
        end

      if date_time_module == DateTime and scale.first.time_zone != "Etc/UTC" and
           step_seconds > 3600 do
        Logger.warning(fn ->
          "DateTimeScale: steps greater than an hour in seconds for non UTC DateTimes are not safe to use because of DST shifts"
        end)
      end

      total_seconds = date_time_module.diff(scale.last, scale.first)
      ticks = trunc(total_seconds / step_seconds)

      0..ticks
      |> Enum.map_reduce(scale.first, fn _i, acc ->
        {acc, date_time_module.add(acc, step_seconds)}
      end)
      |> elem(0)
    end

    def convert_to_range(
          %{first: %date_time_module{}} = scale,
          %date_time_module{} = value,
          to_range
        )
        when date_time_module in [DateTime, NaiveDateTime] do
      if date_time_module.compare(value, scale.first) == :lt or
           date_time_module.compare(value, scale.last) == :gt do
        raise ArgumentError,
          message: "Invalid value `#{inspect(value)}` given for `#{inspect(scale)}`"
      else
        date_time_module.diff(value, scale.first) * (to_range.last - to_range.first) /
          date_time_module.diff(scale.last, scale.first) + to_range.first
      end
    end

    def convert_to_range(scale, value, _to_range) do
      raise ArgumentError,
        message: "Invalid value `#{inspect(value)}` given for `#{inspect(scale)}`"
    end

    defp shift_days(dt, days) do
      dt
      |> shift_by(days, :days)
      |> then(&DateTime.from_naive!(DateTime.to_naive(&1), &1.time_zone))
    end

    # The below `shift` code was taken from Timex, and only supports positive
    # day shifting
    defp shift_by(%DateTime{} = datetime, 0, :days),
      do: datetime

    # Positive shifts
    defp shift_by(%DateTime{year: year, month: month, day: day} = datetime, value, :days)
         when value > 0 do
      ldom = :calendar.last_day_of_the_month(year, month)

      cond do
        day + value <= ldom ->
          %DateTime{datetime | day: day + value}

        month + 1 <= 12 ->
          diff = ldom - day + 1
          shift_by(%DateTime{datetime | month: month + 1, day: 1}, value - diff, :days)

        :else ->
          diff = ldom - day + 1
          shift_by(%DateTime{datetime | year: year + 1, month: 1, day: 1}, value - diff, :days)
      end
    end
  end

  # TODO: inspect for DateTime with time zones is invalid
  defimpl Inspect do
    def inspect(%Plox.DateTimeScale{first: first, last: last}, _) do
      "Plox.DateTimeScale.new(" <> inspect(first) <> ", " <> inspect(last) <> ")"
    end
  end
end
