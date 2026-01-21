defmodule Plox.Helpers.Axis do
  @moduledoc """
  Helper components for rendering axis labels.

  These components wrap common patterns for axis labels using standard SVG elements
  and Plox helper functions. They are convenience wrappers - you can always drop down
  to raw SVG for more control.
  """

  use Phoenix.Component

  import Plox

  alias Plox.Constants

  @doc """
  Renders multiple labels below or above the graph, along the given
  `axis`. Defaults to below.

  Not for use when rendering single labels. It is recommended to use
  SVG `<text>` elements directly for that purpose.

  ## Examples

      <Axis.x_labels :let={date} axis={@x_axis} dimensions={@dimensions} ticks={5}>
        {Calendar.strftime(date, "%-m/%-d")}
      </Axis.x_labels>
  """
  attr :axis, :any, required: true
  attr :dimensions, :any, required: true
  attr :position, :atom, default: :below, values: [:below, :top]
  attr :gap, :integer, default: Constants.default_label_gap()
  attr :ticks, :integer, doc: "Optional number of labels to render (not to be used with `:step`)"
  attr :step, :any, doc: "Optional size of step between label values (not to be used with `:ticks`)"
  attr :start, :any, doc: "Optional starting value for labels"
  attr :rest, :global, include: Constants.svg_presentation_attrs()

  slot :inner_block, required: true

  def x_labels(%{position: :below} = assigns) do
    ~H"""
    <text
      :for={value <- scale_values(@axis, Map.take(assigns, [:ticks, :step, :start]))}
      x={@axis[value]}
      y={below_graph(@dimensions, @gap)}
      text-anchor="middle"
      dominant-baseline="hanging"
      {@rest}
    >
      {render_slot(@inner_block, value)}
    </text>
    """
  end

  def x_labels(%{position: :top} = assigns) do
    ~H"""
    <text
      :for={value <- scale_values(@axis, Map.take(assigns, [:ticks, :step, :start]))}
      x={@axis[value]}
      y={above_graph(@dimensions, @gap)}
      text-anchor="middle"
      dominant-baseline="text-bottom"
      {@rest}
    >
      {render_slot(@inner_block, value)}
    </text>
    """
  end

  @doc """
  Renders multiple labels on the left or right of the graph, along
  the given `axis`. Defaults to the left.

  Not for use when rendering single labels. It is recommended to use
  SVG `<text>` elements directly for that purpose.

  ## Examples

      <Axis.y_labels :let={value} axis={@y_axis} dimensions={@dimensions} ticks={5}>
        {value}
      </Axis.y_labels>
  """
  attr :axis, :any, required: true
  attr :dimensions, :any, required: true
  attr :position, :atom, default: :left, values: [:left, :right]
  attr :gap, :integer, default: Constants.default_label_gap()
  attr :ticks, :integer, doc: "Optional number of labels to render (not to be used with `:step`)"
  attr :step, :any, doc: "Optional size of step between label values (not to be used with `:ticks`)"
  attr :start, :any, doc: "Optional starting value for labels"
  attr :rest, :global, include: Constants.svg_presentation_attrs()

  slot :inner_block, required: true

  def y_labels(%{position: :left} = assigns) do
    ~H"""
    <text
      :for={value <- scale_values(@axis, Map.take(assigns, [:ticks, :step, :start]))}
      x={left_of_graph(@dimensions, @gap)}
      y={@axis[value]}
      text-anchor="end"
      dominant-baseline="middle"
      {@rest}
    >
      {render_slot(@inner_block, value)}
    </text>
    """
  end

  def y_labels(%{position: :right} = assigns) do
    ~H"""
    <text
      :for={value <- scale_values(@axis, Map.take(assigns, [:ticks, :step, :start]))}
      x={right_of_graph(@dimensions, @gap)}
      y={@axis[value]}
      text-anchor="start"
      dominant-baseline="middle"
      {@rest}
    >
      {render_slot(@inner_block, value)}
    </text>
    """
  end
end
