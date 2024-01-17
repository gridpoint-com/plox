defmodule Plox do
  @moduledoc """
  TODO:
  """

  use Phoenix.Component

  alias Plox.Dataset
  alias Plox.DateScale
  alias Plox.Graph
  alias Plox.NumberScale
  alias Plox.Scale

  attr :for, :map, required: true

  attr :width, :integer, required: true, doc: "The total width of the rendered graph, in pixels"
  attr :height, :integer, required: true, doc: "The total height of the rendered graph, in pixels"

  attr :top_gutter, :integer, default: 35, doc: "Top padding in pixels above the graph"
  attr :right_gutter, :integer, default: 70, doc: "Right padding in pixels for the graph"
  attr :bottom_gutter, :integer, default: 35, doc: "Bottom padding in pixels for the x-axis"
  attr :left_gutter, :integer, default: 70, doc: "Left padding in pixels for the y-axis"

  slot :inner_block, required: true

  def graph(assigns) do
    assigns = assign(assigns, :graph, %{assigns.for | dimensions: dimensions(assigns)})

    ~H"""
    <div style={"width: #{@width}px; height: #{@height}px"}>
      <svg viewBox={"0 0 #{@width} #{@height}"} xmlns="http://www.w3.org/2000/svg">
        <%= render_slot(@inner_block, @graph) %>
      </svg>
    </div>
    """
  end

  defp dimensions(assigns) do
    %{
      width: assigns.width,
      height: assigns.height,
      gutters: %{
        top: assigns.top_gutter,
        right: assigns.right_gutter,
        bottom: assigns.bottom_gutter,
        left: assigns.left_gutter
      }
    }
  end

  attr :scale, :any, required: true
  attr :ticks, :any
  attr :step, :any

  attr :position, :atom, values: [:left, :right], default: :left

  attr :grid_lines, :boolean, default: true
  attr :line_width, :string, default: "1"

  slot :inner_block, required: true

  def y_axis(assigns) do
    {scale, dimensions} = assigns.scale
    assigns = assign(assigns, dimensions: dimensions, scale: scale)

    ~H"""
    <%= for y_value <- Scale.values(@scale, scale_opts(assigns)), y_pixel = y_to_graph(y_value, @dimensions, @scale) do %>
      <.y_label dimensions={@dimensions} y_pixel={y_pixel} position={@position}>
        <%= render_slot(@inner_block, y_value) %>
      </.y_label>
      <.horizontal_line
        :if={@grid_lines}
        dimensions={@dimensions}
        y_pixel={y_pixel}
        width={@line_width}
      />
    <% end %>
    """
  end

  attr :scale, :any, required: true
  attr :ticks, :any
  attr :step, :any

  attr :position, :atom, values: [:top, :bottom], default: :bottom

  attr :grid_lines, :boolean, default: true
  attr :line_width, :string, default: "1"

  slot :inner_block, required: true

  def x_axis(assigns) do
    {scale, dimensions} = assigns.scale
    assigns = assign(assigns, dimensions: dimensions, scale: scale)

    ~H"""
    <%= for x_value <- Scale.values(@scale, scale_opts(assigns)), x_pixel = x_to_graph(x_value, @dimensions, @scale) do %>
      <.x_label dimensions={@dimensions} x_pixel={x_pixel} position={@position}>
        <%= render_slot(@inner_block, x_value) %>
      </.x_label>
      <.vertical_line
        :if={@grid_lines}
        dimensions={@dimensions}
        x_pixel={x_pixel}
        width={@line_width}
      />
    <% end %>
    """
  end

  defp scale_opts(assigns) do
    assigns |> Map.take([:ticks, :step]) |> Map.to_list()
  end

  attr :dataset, :any, required: true

  attr :x, :atom, default: :x, doc: "The dataset axis key to use for x values"
  attr :y, :atom, default: :y, doc: "The dataset axis key to use for y values"

  attr :width, :string, examples: ["1.5", "4"], default: "2"

  def line_plot(assigns) do
    {dataset, dimensions} = assigns.dataset
    assigns = assign(assigns, dimensions: dimensions, dataset: dataset)

    ~H"""
    <polyline
      points={
        polyline_points(
          @dataset,
          @dimensions,
          &points/4,
          @dataset.scales[@x],
          @dataset.scales[@y]
        )
      }
      fill="none"
      stroke-width={@width}
      class="stroke-vibrant-orange-300"
    />
    """
  end

  attr :dataset, :any, required: true

  attr :x, :atom, default: :x, doc: "The dataset axis key to use for x values"
  attr :y, :atom, default: :y, doc: "The dataset axis key to use for y values"

  attr :radius, :any, examples: ["8", "24.5", :radius, {:radius, 2, 10}], default: "4"

  def points_plot(assigns) do
    {dataset, dimensions} = assigns.dataset
    assigns = assign(assigns, dimensions: dimensions, dataset: dataset)

    ~H"""
    <circle
      :for={
        {x_pixel, y_pixel, datum} <-
          points(@dataset, @dimensions, @dataset.scales[@x], @dataset.scales[@y])
      }
      cx={x_pixel}
      cy={y_pixel}
      r={radius(@radius, @dimensions, @dataset, datum)}
      class="fill-vibrant-orange-300"
    />
    """
  end

  defp radius(radius, _graph, _dataset, _datum) when is_binary(radius) or is_number(radius),
    do: radius

  defp radius(key, graph, dataset, datum) when is_atom(key) do
    # TODO: infer radius min and max based on graph dimensions
    radius({key, 2, 20}, graph, dataset, datum)
  end

  defp radius({key, min, max}, _graph, dataset, datum) do
    Scale.convert_to_range(dataset.scales[key], datum[key], min..max) |> to_string()
  end

  attr :dimensions, :map, required: true
  attr :y_pixel, :float, required: true, doc: "Y pixel value for rendering this label"
  attr :position, :atom, required: true, values: [:left, :right]

  slot :inner_block, required: true

  defp y_label(%{position: :left} = assigns) do
    ~H"""
    <text
      x={@dimensions.gutters.left - 16}
      y={@y_pixel}
      class="fill-grey-1000 text-xs [dominant-baseline:middle] [text-anchor:end]"
    >
      <%= render_slot(@inner_block) %>
    </text>
    """
  end

  defp y_label(%{position: :right} = assigns) do
    ~H"""
    <text
      x={@dimensions.width - @dimensions.gutters.right + 16}
      y={@y_pixel}
      class="fill-grey-1000 text-xs [dominant-baseline:middle] [text-anchor:start]"
    >
      <%= render_slot(@inner_block) %>
    </text>
    """
  end

  attr :dimensions, :map, required: true
  attr :x_pixel, :float, required: true, doc: "X pixel value for rendering this label"
  attr :position, :atom, required: true, values: [:top, :bottom]

  slot :inner_block, required: true

  defp x_label(%{position: :bottom} = assigns) do
    ~H"""
    <text
      x={@x_pixel}
      y={@dimensions.height - @dimensions.gutters.bottom + 16}
      class="fill-grey-1000 text-xs [dominant-baseline:hanging] [text-anchor:middle]"
    >
      <%= render_slot(@inner_block) %>
    </text>
    """
  end

  defp x_label(%{position: :top} = assigns) do
    ~H"""
    <text
      x={@x_pixel}
      y={@dimensions.gutters.bottom - 16}
      class="fill-grey-1000 text-xs [dominant-baseline:text-bottom] [text-anchor:middle]"
    >
      <%= render_slot(@inner_block) %>
    </text>
    """
  end

  attr :dimensions, :map, required: true
  attr :y_pixel, :float, required: true
  attr :width, :string, required: true

  defp horizontal_line(assigns) do
    ~H"""
    <line
      x1={@dimensions.gutters.left}
      y1={@y_pixel}
      x2={@dimensions.width - @dimensions.gutters.right}
      y2={@y_pixel}
      stroke-width={@width}
      class="stroke-grey-50"
    />
    """
  end

  attr :dimensions, :map, required: true
  attr :x_pixel, :float, required: true
  attr :width, :string, required: true

  defp vertical_line(assigns) do
    ~H"""
    <line
      x1={@x_pixel}
      y1={@dimensions.gutters.top}
      x2={@x_pixel}
      y2={@dimensions.height - @dimensions.gutters.bottom}
      stroke-width={@width}
      class="stroke-grey-50"
    />
    """
  end

  attr :marker, :any, required: true
  attr :width, :string, default: "1.5"

  slot :inner_block, required: true

  def vertical_marker(assigns) do
    {{value, scale}, dimensions} = assigns.marker
    x_pixel = x_to_graph(value, dimensions, scale)
    assigns = assign(assigns, dimensions: dimensions, x_pixel: x_pixel)

    ~H"""
    <line
      x1={@x_pixel}
      y1={@dimensions.gutters.top - 12}
      x2={@x_pixel}
      y2={@dimensions.height - @dimensions.gutters.bottom}
      stroke-width={@width}
      class="stroke-grey-1000 [stroke-dasharray:2]"
    />
    <text
      x={@x_pixel}
      y={@dimensions.gutters.top - 24}
      class={["fill-grey-1000", "text-xs [dominant-baseline:middle] [text-anchor:middle]"]}
    >
      <%= render_slot(@inner_block) %>
    </text>
    """
  end

  defp polyline_points(dataset, graph, points_fun, x_scale, y_scale) do
    dataset
    |> points_fun.(graph, x_scale, y_scale)
    |> Enum.map_join(" ", fn {x, y, _} -> "#{x},#{y}" end)
  end

  defp points(dataset, graph, x_scale, y_scale) do
    for %{x: x_value, y: y_value} = datum <- dataset.data do
      {x_to_graph(x_value, graph, x_scale), y_to_graph(y_value, graph, y_scale), datum}
    end
  end

  defp x_to_graph(x_value, graph, scale) do
    Scale.convert_to_range(
      scale,
      x_value,
      graph.gutters.left..(graph.width - graph.gutters.right)
    )
  end

  defp y_to_graph(y_value, graph, scale) do
    Scale.convert_to_range(
      scale,
      y_value,
      (graph.height - graph.gutters.bottom)..graph.gutters.top
    )
  end

  defdelegate to_graph(scales_and_datasets), to: Graph, as: :new
  defdelegate date_scale(range), to: DateScale, as: :new
  defdelegate number_scale(first, last), to: NumberScale, as: :new
  defdelegate dataset(data, aces), to: Dataset, as: :new
end
