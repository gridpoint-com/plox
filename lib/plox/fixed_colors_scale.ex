defmodule Plox.FixedColorsScale do
  @moduledoc """
  A color scale for mapping a set of known fixed values to a set of known fixed
  colors.

  This struct implements the `Plox.ColorScale` protocol.

  `Plox.ColorScale.convert_to_color/2` returns the color for a given value:

      iex> scale = Plox.FixedColorsScale.new(%{red: "#ff0000", green: "#00ff00", blue: "#0000ff"})
      iex> Plox.ColorScale.convert_to_color(scale, :red)
      "#ff0000"
  """

  defstruct [:mapping]

  @doc """
  Creates a new `Plox.FixedColorsScale` struct.

  Raises if the given `mapping` is not a map or contains fewer than two entries.

  ## Example

      iex> Plox.FixedColorsScale.new(%{red: "#ff0000", green: "#00ff00", blue: "#0000ff"})
      %Plox.FixedColorsScale{
        mapping: %{red: "#ff0000", green: "#00ff00", blue: "#0000ff"}
      }
  """
  def new(mapping) when not is_struct(mapping) and map_size(mapping) >= 2 do
    %__MODULE__{mapping: mapping}
  end

  def new(_mapping) do
    raise ArgumentError,
      message: "Invalid FixedColorsScale: must be a map with at least two entries"
  end

  defimpl Plox.ColorScale do
    @doc """
    Converts a given `value` from the scale to its corresponding color.

    Raises if `value` is not a key within the scale.
    """
    def convert_to_color(scale, value) do
      case Map.fetch(scale.mapping, value) do
        {:ok, color} ->
          color

        :error ->
          raise ArgumentError,
            message: "Invalid value `#{inspect(value)}` given for `#{inspect(scale)}`"
      end
    end
  end

  defimpl Inspect do
    def inspect(%Plox.FixedColorsScale{mapping: mapping}, _) do
      "Plox.FixedColorsScale.new(" <> inspect(mapping) <> ")"
    end
  end
end
