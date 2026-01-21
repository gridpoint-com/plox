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
  Renders vertical lines at values along the given `axis`.

  ## Examples

      <.vertical_lines axis={@x_axis} dimensions={@dimensions} ticks={5} />
  """
  attr :axis, :any, required: true
  attr :dimensions, :any, required: true
  attr :ticks, :integer, doc: "Optional number of lines to render (not to be used with `:step`)"
  attr :step, :any, doc: "Optional size of step between line values (not to be used with `:ticks`)"
  attr :start, :any, doc: "Optional starting value for lines"
  attr :stroke, :string, default: "#D3D3D3"
  attr :rest, :global, include: Constants.svg_presentation_attrs()

  def vertical_lines(assigns) do
    ~H"""
    <line
      :for={value <- scale_values(@axis, Map.take(assigns, [:ticks, :step, :start]))}
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
  Renders horizontal lines at values along the given `axis`.

  ## Examples

      <.horizontal_lines axis={@y_axis} dimensions={@dimensions} ticks={5} />
  """
  attr :axis, :any, required: true
  attr :dimensions, :any, required: true
  attr :ticks, :integer, doc: "Optional number of lines to render (not to be used with `:step`)"
  attr :step, :any, doc: "Optional size of step between line values (not to be used with `:ticks`)"
  attr :start, :any, doc: "Optional starting value for lines"
  attr :stroke, :string, default: "#D3D3D3"
  attr :rest, :global, include: Constants.svg_presentation_attrs()

  def horizontal_lines(assigns) do
    ~H"""
    <line
      :for={value <- scale_values(@axis, Map.take(assigns, [:ticks, :step, :start]))}
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
