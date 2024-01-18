defmodule Plox.FixedValuesScale do
  @moduledoc """
  A scale that represents an arbitrary set of values.

  It places the values in the given order with equal distance between them.

  This struct implements the `Plox.Scale` protocol.
  """
  defstruct [:values, :index_map, :max_index]

  @type t :: %__MODULE__{}

  @doc """
  Creates a new `Plox.FixedValuesScale` struct

  Accepts any enumerable.
  """
  @spec new(values :: Enumerable.t()) :: t()
  def new(values) do
    values = Enum.into(values, [])

    index_map =
      values
      |> Enum.with_index()
      |> Map.new()

    count = Enum.count(values)

    if count <= 1 do
      raise ArgumentError,
        message: "Invalid FixedValuesScale: there must be at least two values in the scale"
    end

    %__MODULE__{values: values, index_map: index_map, max_index: count - 1}
  end

  defimpl Plox.Scale do
    def values(scale, _opts), do: scale.values

    def convert_to_range(scale, value, to_range) do
      case Map.fetch(scale.index_map, value) do
        {:ok, value_index} ->
          value_index * (to_range.last - to_range.first) / scale.max_index + to_range.first

        :error ->
          raise ArgumentError,
            message: "Invalid value `#{inspect(value)}` given for `#{inspect(scale)}`"
      end
    end
  end

  defimpl Inspect do
    def inspect(%Plox.FixedValuesScale{values: values}, _) do
      "Plox.FixedValuesScale.new(" <> inspect(values) <> ")"
    end
  end
end
