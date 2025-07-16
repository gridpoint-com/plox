defmodule Plox.FixedValuesScale do
  @moduledoc """
  A scale that represents an arbitrary set of values.

  It places the values in the given order with equal distance between them.

  This struct implements the `Plox.Scale` protocol.
  """
  defstruct [:values, :index_map, :max_index]

  @type t :: %__MODULE__{}

  @doc """
  Creates a new `Plox.FixedValuesScale` struct.

  Raises if given an enumerable with less than two values.

  ## Example

      iex> Plox.FixedValuesScale.new([1, 2, 3, 4])
      %Plox.FixedValuesScale{
        values: [1, 2, 3, 4],
        index_map: %{1 => 0, 2 => 1, 3 => 2, 4 => 3},
        max_index: 3
      }

      iex> Plox.FixedValuesScale.new(["a", "b", "c"])
      %Plox.FixedValuesScale{
        values: ["a", "b", "c"],
        index_map: %{"a" => 0, "b" => 1, "c" => 2},
        max_index: 2
      }
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
    @doc """
    Returns an enumerable of the `values` in the scale.

    ## Example

        iex> scale = Plox.FixedValuesScale.new([:a, :b, :c])
        iex> Plox.Scale.values(scale)
        [:a, :b, :c]
    """
    def values(scale, _opts), do: scale.values

    @doc """
    Converts a given `value` from the scale to a number in the given `to_range`.

    Raises if `value` is not within the scale.

    ## Example

        iex> scale = Plox.FixedValuesScale.new([:a, :b, :c])
        iex> Plox.Scale.convert_to_range(scale, :b, 0..100)
        50.0
    """
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
