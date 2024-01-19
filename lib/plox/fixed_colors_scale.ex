defmodule Plox.FixedColorsScale do
  @moduledoc """
  A color scale for mapping a set of known fixed values to a set of known fixed
  colors.
  """

  defstruct [:mapping]

  def new(mapping) do
    %__MODULE__{mapping: mapping}
  end

  defimpl Plox.ColorScale do
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
