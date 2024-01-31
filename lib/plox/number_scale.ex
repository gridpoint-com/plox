defmodule Plox.NumberScale do
  @moduledoc """
  An arbitrary precision number scale

  This struct implements the `Plox.Scale` protocol.

  Although internally we use `Decimal` for arbitrary precision and accurate
  math, this scale expects floats as input and produces floats as output, so
  there's still some room for floating point imprecision.
  """
  defstruct [:first, :last, :backwards?]

  @type t :: %__MODULE__{}

  @doc """
  Creates a new `Plox.NumberScale` struct

  Accepts 2 numbers as `first` and `last` as well as the number of `ticks` that
  should comprise the scale. The in-between values for these ticks are
  dynamically calculated based on `first`, `last`, and `ticks`.

  `ticks` must be at least `2`.
  """
  @spec new(first :: number(), last :: number()) :: t()
  def new(first, last) when is_number(first) and is_number(last) and first != last do
    first = Decimal.from_float(first / 1.0)
    last = Decimal.from_float(last / 1.0)
    backwards? = Decimal.compare(first, last) == :gt

    %__MODULE__{
      first: first,
      last: last,
      backwards?: backwards?
    }
  end

  def new(_first, _last) do
    raise ArgumentError,
      message: "Invalid NumberScale: First and last must be numbers and cannot be equivalent."
  end

  defimpl Plox.Scale do
    def values(scale, opts \\ %{}) do
      ticks = Map.get(opts, :ticks, 11)
      step = scale.last |> Decimal.sub(scale.first) |> Decimal.div(ticks - 1)

      # we don't compute the last value because it could include rounding errors
      # carried through each step, instead we just append `scale.last`
      0..(ticks - 2)
      |> Enum.map_reduce(scale.first, fn _i, acc -> {acc, Decimal.add(acc, step)} end)
      |> elem(0)
      |> Kernel.++([scale.last])
      |> Enum.map(&Decimal.to_float/1)
    end

    def convert_to_range(scale, input_value, to_range) when is_number(input_value) do
      value = Decimal.from_float(input_value / 1.0)

      if in_range?(scale, value) do
        raise ArgumentError,
          message: "Invalid value `#{inspect(input_value)}` given for `#{inspect(scale)}`"
      else
        value
        |> Decimal.sub(scale.first)
        |> Decimal.mult(to_range.last - to_range.first)
        |> Decimal.div(Decimal.sub(scale.last, scale.first))
        |> Decimal.add(to_range.first)
        |> Decimal.to_float()
      end
    end

    def convert_to_range(scale, value, _to_range) do
      raise ArgumentError,
        message: "Invalid value `#{inspect(value)}` given for `#{inspect(scale)}`"
    end

    defp in_range?(%{backwards?: true} = scale, value) do
      Decimal.compare(value, scale.last) == :lt or Decimal.compare(value, scale.first) == :gt
    end

    defp in_range?(scale, value) do
      Decimal.compare(value, scale.first) == :lt or Decimal.compare(value, scale.last) == :gt
    end
  end

  defimpl Inspect do
    def inspect(%Plox.NumberScale{first: first, last: last}, _) do
      "Plox.NumberScale.new(" <>
        inspect(Decimal.to_float(first)) <> ", " <> inspect(Decimal.to_float(last)) <> ")"
    end
  end
end
