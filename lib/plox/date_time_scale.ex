defmodule Plox.DateTimeScale do
  @moduledoc """
  A scale of datetime values (`t:DateTime.t/0` or `t:NaiveDateTime.t/0`).

  This struct implements the `Plox.Scale` protocol.

  `Plox.Scale.values/2` returns a list of all datetime values:

      iex> scale = Plox.DateTimeScale.new(~N[2019-01-01 00:00:00], ~N[2019-01-01 00:03:00])
      iex> Plox.Scale.values(scale)
      [~N[2019-01-01 00:00:00], ~N[2019-01-01 00:01:00], ~N[2019-01-01 00:02:00], ~N[2019-01-01 00:03:00]]

      iex> scale = Plox.DateTimeScale.new(~U[2019-01-01 00:00:00Z], ~U[2019-01-03 00:00:00Z])
      iex> Plox.Scale.values(scale, %{step: {1, :day}})
      [~U[2019-01-01 00:00:00Z], ~U[2019-01-02 00:00:00Z], ~U[2019-01-03 00:00:00Z]]

  `Plox.Scale.convert_to_range/3` returns a number in the given range:

      iex> scale = Plox.DateTimeScale.new(~N[2019-01-01 00:00:00], ~N[2019-01-03 00:00:00])
      iex> Plox.Scale.convert_to_range(scale, ~N[2019-01-02 00:00:00], 0..100)
      50.0
  """
  require Logger

  defstruct [:first, :last]

  @type t :: %__MODULE__{}
  @type datetime :: DateTime.t() | NaiveDateTime.t()

  @doc """
  Creates a new `Plox.DateTimeScale` struct.

  Accepts 2 datetime structs as `first` and `last` (`t:DateTime.t/0` or `t:NaiveDateTime.t/0`).
  Raises if `first` and `last` are not the same struct or if `first` is not before `last`.
  Negative ranges are not currently supported.

  ## Example

      iex> Plox.DateTimeScale.new(~N[2019-01-01 00:00:00], ~N[2019-01-03 00:00:00])
      %Plox.DateTimeScale{first: ~N[2019-01-01 00:00:00], last: ~N[2019-01-03 00:00:00]}

      iex> Plox.DateTimeScale.new(~U[2019-01-01 00:00:00Z], ~U[2019-01-03 00:00:00Z])
      %Plox.DateTimeScale{first: ~U[2019-01-01 00:00:00Z], last: ~U[2019-01-03 00:00:00Z]}
  """
  @spec new(first :: datetime(), last :: datetime()) :: t()
  def new(first, last)

  def new(%date_time_module{} = first, %date_time_module{} = last) when date_time_module in [DateTime, NaiveDateTime] do
    if date_time_module.diff(last, first) <= 0 do
      raise ArgumentError,
        message: "Invalid DateTimeScale: The range must be at least 1 second long and `first` must come before `last`"
    end

    %__MODULE__{first: first, last: last}
  end

  def new(_first, _last) do
    raise ArgumentError,
      message: "Invalid DateTimeScale: First and last must both be DateTime or NaiveDateTime structs"
  end

  defimpl Plox.Scale do
    @doc """
    Returns a list of all `DateTime` or `NaiveDateTime` values in the scale,
    stepping by the given interval.

    Accepts a `:step` option, which can be a number of seconds, minutes, hours,
    or days. The default step is 60 seconds.
    """
    def values(%{first: %DateTime{time_zone: tz}} = scale, %{step: {step_days, :day}}) when tz != "Etc/UTC" do
      scale.first
      |> Stream.unfold(fn current_dt ->
        if DateTime.after?(current_dt, scale.last) do
          nil
        else
          {current_dt, shift_days(current_dt, step_days)}
        end
      end)
      |> Enum.to_list()
    end

    def values(%{first: %date_time_module{}} = scale, opts) do
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

      first_value = Map.get(opts, :start, scale.first)

      total_seconds = date_time_module.diff(scale.last, first_value)
      ticks = trunc(total_seconds / step_seconds)

      0..ticks
      |> Enum.map_reduce(first_value, fn _i, acc ->
        {acc, date_time_module.add(acc, step_seconds)}
      end)
      |> elem(0)
    end

    @doc """
    Converts a datetime `value` from the scale to a number in the given `to_range`.

    Raises if `value` is not a valid datetime included in the scale.
    """
    def convert_to_range(%{first: %date_time_module{}} = scale, %date_time_module{} = value, to_range)
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
    defp shift_by(%DateTime{} = datetime, 0, :days), do: datetime

    # Positive shifts
    defp shift_by(%DateTime{year: year, month: month, day: day} = datetime, value, :days) when value > 0 do
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
