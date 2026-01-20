defmodule Plox.Helpers.Grid do
  @moduledoc """
  Helper components for rendering grid lines.

  These components wrap common patterns for axis labels using standard SVG elements
  and Plox helper functions. They are convenience wrappers - you can always drop down
  to raw SVG for more control.
  """

  use Phoenix.Component

  import Plox

  alias Plox.Constants

  @doc """
  Renders vertical grid lines at X-axis tick positions.
  """
  attr :axis, :any, required: true
  attr :dimensions, :any, required: true
  attr :ticks, :integer, required: true
  attr :step, :any
  attr :stroke, :string, default: "#D3D3D3"
  attr :rest, :global, include: Constants.svg_presentation_attrs()

  def x_lines(assigns) do
    ~H"""
    <line
      :for={value <- scale_values(@axis, Map.take(assigns, [:ticks, :step]))}
      x1={x = @axis[value]}
      x2={x}
      y1={graph_top(@dimensions)}
      y2={graph_bottom(@dimensions)}
      stroke={@stroke}
      {@rest}
    />
    """
  end

  @doc """
  Renders horizontal grid lines at Y-axis tick positions.
  """
  attr :axis, :any, required: true
  attr :dimensions, :any, required: true
  attr :ticks, :integer, required: true
  attr :step, :any
  attr :stroke, :string, default: "#D3D3D3"
  attr :rest, :global, include: Constants.svg_presentation_attrs()

  def y_lines(assigns) do
    ~H"""
    <line
      :for={value <- scale_values(@axis, Map.take(assigns, [:ticks, :step]))}
      x1={graph_left(@dimensions)}
      x2={graph_right(@dimensions)}
      y1={y = @axis[value]}
      y2={y}
      stroke={@stroke}
      {@rest}
    />
    """
  end
end
