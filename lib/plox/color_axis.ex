defmodule Plox.ColorAxis do
  @moduledoc """
  ColorAxis converts `Plox.ColorScale` values to graphable colors.

  This module implements the `Access` behaviour, allowing access to graphable
  values using the `[]` syntax.

  ## Example

      iex> color_scale = Plox.FixedColorsScale.new(%{red: "#ff0000", green: "#00ff00", blue: "#0000ff"})
      iex> color_axis = Plox.ColorAxis.new(color_scale)
      iex> color_axis[:green]
      "#00ff00"

  This is useful when rendering graph elements in a more intuitive way:

      <!-- Draw a red circle (at the given coordinates) -->
      <.circle cx={50.0} cy={75.0} fill={color_axis[:red]} r="3" />

  This module implements the `Plox.Axis.Protocol` and defines the `Plox.Axis.Protocol.to_graph/2`
  function. This function is called by the `Access` behaviour:

      iex> color_scale = Plox.FixedColorsScale.new(%{red: "#ff0000", green: "#00ff00", blue: "#0000ff"})
      iex> color_axis = Plox.ColorAxis.new(color_scale)
      iex> color_axis[:blue] == Plox.Axis.Protocol.to_graph(color_axis, :blue)
      true
  """

  use Plox.Axis

  alias Plox.ColorScale

  defstruct [:scale]

  @doc """
  Creates a new `Plox.ColorAxis` struct.

  Accepts a `Plox.ColorScale` struct.

  ## Example

      iex> color_scale = Plox.FixedColorsScale.new(%{red: "#ff0000", green: "#00ff00", blue: "#0000ff"})
      iex> Plox.ColorAxis.new(color_scale)
      %Plox.ColorAxis{scale: color_scale}
  """
  def new(scale) do
    %__MODULE__{scale: scale}
  end

  defimpl Plox.Axis.Protocol do
    @doc """
    Converts the given `value` to a graphable color.
    """
    def to_graph(%{scale: scale}, value) do
      ColorScale.convert_to_color(scale, value)
    end
  end
end
