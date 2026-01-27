defmodule Plox.DateScale do
  @moduledoc """
  A scale of date values (`t:Date.t/0`).

  This struct implements the `Plox.Scale` protocol.

  `Plox.Scale.values/2` returns a `t:Date.Range.t/0` enumerable and accepts
  `step` and `start` options:

      iex> scale = Plox.DateScale.new(Date.range(~D[2020-01-01], ~D[2020-01-10], 1))
      iex> scale |> Plox.Scale.values(%{step: 2}) |> Enum.to_list()
      [~D[2020-01-01], ~D[2020-01-03], ~D[2020-01-05], ~D[2020-01-07], ~D[2020-01-09]]

      iex> scale = Plox.DateScale.new(Date.range(~D[2020-01-10], ~D[2020-01-01], -1))
      iex> scale |> Plox.Scale.values(%{step: 3}) |> Enum.to_list()
      [~D[2020-01-10], ~D[2020-01-07], ~D[2020-01-04], ~D[2020-01-01]]

      iex> scale = Plox.DateScale.new(Date.range(~D[2020-01-01], ~D[2020-01-10], 1))
      iex> scale |> Plox.Scale.values(%{start: ~D[2020-01-07]}) |> Enum.to_list()
      [~D[2020-01-07], ~D[2020-01-08], ~D[2020-01-09], ~D[2020-01-10]]

  `Plox.Scale.convert_to_range/3` returns a number in the given range:

      iex> scale = Plox.DateScale.new(Date.range(~D[2020-01-01], ~D[2020-01-09], 1))
      iex> Plox.Scale.convert_to_range(scale, ~D[2020-01-05], 0..100)
      50.0

      iex> scale = Plox.DateScale.new(Date.range(~D[2020-01-09], ~D[2020-01-01], -1))
      iex> Plox.Scale.convert_to_range(scale, ~D[2020-01-07], 0..100)
      25.0
  """
  defstruct [:range]

  @type t :: %__MODULE__{}

  @doc """
  Creates a new `Plox.DateScale` struct.

  Raises if `range` is not a `t:Date.Range.t/0` struct or if it does not contain at least
  two dates. The step is ignored. Supports forward and backward ranges.

  ## Example

      iex> Plox.DateScale.new(Date.range(~D[2020-01-01], ~D[2020-01-10], 1))
      %Plox.DateScale{range: Date.range(~D[2020-01-01], ~D[2020-01-10], 1)}

      iex> Plox.DateScale.new(Date.range(~D[2020-01-10], ~D[2020-01-01], -1))
      %Plox.DateScale{range: Date.range(~D[2020-01-10], ~D[2020-01-01], -1)}
  """
  @spec new(range :: Date.Range.t()) :: t()
  def new(%Date.Range{} = range) do
    range = reduce_step(range)

    if Enum.count(range) <= 1 do
      raise ArgumentError,
        message: "Invalid DateScale: there must be at least two dates in the range"
    end

    %__MODULE__{range: range}
  end

  def new(_range) do
    raise ArgumentError,
      message: "Invalid DateScale: must be a Date.Range struct with at least two dates"
  end

  defp reduce_step(%Date.Range{step: step} = range) when step > 0, do: Date.range(range.first, range.last, 1)
  defp reduce_step(%Date.Range{step: step} = range) when step < 0, do: Date.range(range.first, range.last, -1)

  defimpl Plox.Scale do
    @doc """
    Returns a `t:Date.Range.t/0` of all `t:Date.t/0` values in the scale,
    stepping by the given interval.

    Maintains the direction of the original range (positive or negative).

    ## Options

      * `:start` - The starting date for generating values. Must be a `t:Date.t/0`
        within the scale's domain. Defaults to the first date in the scale's range.

      * `:step` - The number of days between each value. Must be a positive integer.
        Defaults to `1`.
    """
    def values(scale, opts) do
      first_value = Map.get(opts, :start, scale.range.first)
      step = Map.get(opts, :step, 1)

      unless first_value in scale.range do
        raise ArgumentError, message: "DateScale: start value must be within the range of the scale"
      end

      if step < 1 do
        raise ArgumentError, message: "DateScale: step must be a positive integer"
      end

      if scale.range.step > 0 do
        Date.range(first_value, scale.range.last, step)
      else
        Date.range(first_value, scale.range.last, -step)
      end
    end

    @doc """
    Converts a date `value` from the scale to a number in the given `to_range`.

    Raises if `value` is not a valid date included in the scale.
    """
    def convert_to_range(scale, %Date{} = value, to_range) do
      range = scale.range

      if value in range do
        Date.diff(value, range.first) * (to_range.last - to_range.first) /
          Date.diff(range.last, range.first) + to_range.first
      else
        raise ArgumentError,
          message: "Invalid value `#{inspect(value)}` given for `#{inspect(scale)}`"
      end
    end

    def convert_to_range(scale, value, _to_range) do
      raise ArgumentError,
        message: "Invalid value `#{inspect(value)}` given for `#{inspect(scale)}`"
    end
  end

  defimpl Inspect do
    def inspect(%Plox.DateScale{range: range}, _) do
      "Plox.DateScale.new(" <> inspect(range) <> ")"
    end
  end
end
