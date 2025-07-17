defmodule Plox.NumberScale do
  @moduledoc """
  An arbitrary precision number scale.

  Although internally we use `Decimal` for arbitrary precision and accurate
  math, this scale expects floats as input and produces floats as output,
  which may lead to floating point imprecision.

  This struct implements the `Plox.Scale` protocol.

  `Plox.Scale.values/2` returns an enumerable of the numerical values in the scale:

      iex> scale = Plox.NumberScale.new(0, 10)
      iex> Plox.Scale.values(scale)
      [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]

      iex> scale = Plox.NumberScale.new(10, 0)
      iex> Plox.Scale.values(scale, %{ticks: 6})
      [10.0, 8.0, 6.0, 4.0, 2.0, 0.0]

  `Plox.Scale.convert_to_range/3` returns a number in the given range:

      iex> scale = Plox.NumberScale.new(0, 10)
      iex> Plox.Scale.convert_to_range(scale, 5, 0..100)
      50.0

      iex> scale = Plox.NumberScale.new(10, 0)
      iex> Plox.Scale.convert_to_range(scale, 2, 0..100)
      80.0
  """
  defstruct [:first, :last, :backwards?]

  @type t :: %__MODULE__{}

  @doc """
  Creates a new `Plox.NumberScale` struct.

  Accepts 2 numbers as `first` and `last` values. Dynamically determines
  if the scale is backwards (i.e. `first` is greater than `last`).

  Raises if given equivalent numbers or if either `first` or `last` is not a number.

  ## Example

      iex> Plox.NumberScale.new(0, 10)
      %Plox.NumberScale{first: Decimal.new("0.0"), last: Decimal.new("10.0"), backwards?: false}

      iex> Plox.NumberScale.new(10, 0)
      %Plox.NumberScale{first: Decimal.new("10.0"), last: Decimal.new("0.0"), backwards?: true}
  """
  @spec new(first :: number(), last :: number()) :: t()
  def new(first, last) when is_number(first) and is_number(last) and first != last do
    first = Decimal.from_float(first / 1.0)
    last = Decimal.from_float(last / 1.0)
    backwards? = Decimal.compare(first, last) == :gt

    %__MODULE__{first: first, last: last, backwards?: backwards?}
  end

  def new(_first, _last) do
    raise ArgumentError,
      message: "Invalid NumberScale: First and last must be numbers and cannot be equivalent"
  end

  defimpl Plox.Scale do
    @doc """
    Returns an enumerable of the numerical values in the scale. Optionally accepts a
    number of `ticks` to specify how many values to return. The in-between values are
    dynamically calculated based on `first`, `last`, and `ticks`.

    Raises if `ticks` is less than `2` (default is `11`).
    """
    def values(scale, opts) do
      ticks = Map.get(opts, :ticks, 11)

      if ticks < 2 do
        raise ArgumentError, message: "Invalid ticks count `#{ticks}`, must be at least 2"
      end

      step = scale.last |> Decimal.sub(scale.first) |> Decimal.div(ticks - 1)

      # we don't compute the last value because it could include rounding errors
      # carried through each step, instead we just append `scale.last`
      0..(ticks - 2)
      |> Enum.map_reduce(scale.first, fn _i, acc -> {acc, Decimal.add(acc, step)} end)
      |> elem(0)
      |> Kernel.++([scale.last])
      |> Enum.map(&Decimal.to_float/1)
    end

    @doc """
    Converts a number from the scale to a number in the given `to_range`. The given
    `input_value` must be a number inclusively within the `scale` bounds.

    Raises if `input_value` is out of bounds or not a number.
    """
    def convert_to_range(scale, input_value, to_range) when is_number(input_value) do
      value = Decimal.from_float(input_value / 1.0)
      lower = if scale.backwards?, do: scale.last, else: scale.first
      upper = if scale.backwards?, do: scale.first, else: scale.last

      if Decimal.gt?(value, upper) || Decimal.lt?(value, lower) do
        raise ArgumentError,
          message: "Input value `#{inspect(input_value)}` is out of bounds for `#{inspect(scale)}`"
      end

      value
      |> Decimal.sub(scale.first)
      |> Decimal.mult(to_range.last - to_range.first)
      |> Decimal.div(Decimal.sub(scale.last, scale.first))
      |> Decimal.add(to_range.first)
      |> Decimal.to_float()
    end

    def convert_to_range(scale, value, _to_range) do
      raise ArgumentError,
        message: "Invalid value `#{inspect(value)}` given for `#{inspect(scale)}`"
    end
  end

  defimpl Inspect do
    def inspect(%Plox.NumberScale{first: first, last: last}, _) do
      "Plox.NumberScale.new(" <>
        inspect(Decimal.to_float(first)) <> ", " <> inspect(Decimal.to_float(last)) <> ")"
    end
  end
end
