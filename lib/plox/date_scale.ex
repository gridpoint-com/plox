defmodule Plox.DateScale do
  @moduledoc """
  A scale for elixir `Date` values

  This struct implements the `Plox.Scale` protocol.
  """
  defstruct [:range]

  @type t :: %__MODULE__{}

  @doc """
  Creates a new `Plox.DateScale` struct

  Accepts an elixir `Date.Range` struct. The range must contain at least two
  dates. The step is ignored. Supports forward and backward ranges.
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

  defp reduce_step(%Date.Range{step: step} = range) when step > 0,
    do: Date.range(range.first, range.last, 1)

  defp reduce_step(%Date.Range{step: step} = range) when step < 0,
    do: Date.range(range.first, range.last, -1)

  defimpl Plox.Scale do
    def values(scale, opts) do
      case Map.fetch(opts, :step) do
        :error -> scale.range
        {:ok, step} when scale.range.step > 0 -> %{scale.range | step: step}
        {:ok, step} when scale.range.step < 0 -> %{scale.range | step: -step}
      end
    end

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
