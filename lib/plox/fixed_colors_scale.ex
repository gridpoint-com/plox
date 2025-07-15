defmodule Plox.FixedColorsScale do
  @moduledoc """
  A color scale for mapping a set of known fixed values to a set of known fixed
  colors.

  This struct implements the `Plox.ColorScale` protocol.
  """

  defstruct [:mapping]

  @doc """
  Creates a new `Plox.FixedColorsScale` struct.

  Accepts a map with at least two entries.

  ## Example

      iex> Plox.FixedColorsScale.new(%{red: "#ff0000", green: "#00ff00", blue: "#0000ff"})
      %Plox.FixedColorsScale{
        mapping: %{red: "#ff0000", green: "#00ff00", blue: "#0000ff"}
      }
  """
  def new(mapping) when is_non_struct_map(mapping) and map_size(mapping) >= 2 do
    %__MODULE__{mapping: mapping}
  end

  def new(_mapping) do
    raise ArgumentError,
      message: "Invalid FixedColorsScale: must be a map with at least two entries"
  end

  defimpl Plox.ColorScale do
    @doc """
    Converts a given `value` from the `scale` to its corresponding color.

    ## Example

        iex> scale = Plox.FixedColorsScale.new(%{red: "#ff0000", green: "#00ff00", blue: "#0000ff"})
        iex> Plox.ColorScale.convert_to_color(scale, :red)
        "#ff0000"
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
