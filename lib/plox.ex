defmodule Plox do
  @moduledoc """
  TODO:
  """

  use Phoenix.Component

  alias Plox.ColorScale
  alias Plox.Dataset
  alias Plox.DateScale
  alias Plox.DateTimeScale
  alias Plox.FixedColorsScale
  alias Plox.FixedValuesScale
  alias Plox.Graph
  alias Plox.NumberScale
  alias Plox.Scale

  attr :for, :map, required: true

  attr :id, :string, required: true
  attr :width, :integer, required: true, doc: "The total width of the rendered graph, in pixels"
  attr :height, :integer, required: true, doc: "The total height of the rendered graph, in pixels"

  attr :top_gutter, :integer, default: 35, doc: "Top padding in pixels above the graph"
  attr :right_gutter, :integer, default: 70, doc: "Right padding in pixels for the graph"
  attr :bottom_gutter, :integer, default: 35, doc: "Bottom padding in pixels for the x-axis"
  attr :left_gutter, :integer, default: 70, doc: "Left padding in pixels for the y-axis"

  slot :legend
  slot :inner_block, required: true

  def graph(assigns) do
    assigns = assign(assigns, :graph, %{assigns.for | dimensions: dimensions(assigns)})

    ~H"""
    <div id={@id}>
      <div style={"display: flex; flex-direction: column; align-items: flex-end; max-width: #{@graph.dimensions.width - @graph.dimensions.gutters.right}px"}>
        <.legend :for={legend <- @legend}>
          <%= render_slot(legend) %>
        </.legend>
      </div>
      <div style={"width: #{@width}px; height: #{@height}px"}>
        <svg viewBox={"0 0 #{@width} #{@height}"} xmlns="http://www.w3.org/2000/svg">
          <%= render_slot(@inner_block, @graph) %>
        </svg>
      </div>
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

  attr :label_color, :string, default: "#18191A"

  attr :grid_lines, :boolean, default: true
  attr :line_width, :string, default: "1"
  attr :line_color, :string, default: "#F2F4F5"

  slot :inner_block, required: true

  def y_axis(assigns) do
    {scale, dimensions} = assigns.scale
    assigns = assign(assigns, dimensions: dimensions, scale: scale)

    ~H"""
    <%= for y_value <- Scale.values(@scale, scale_opts(assigns)), y_pixel = y_to_graph(y_value, @dimensions, @scale) do %>
      <.y_label dimensions={@dimensions} y_pixel={y_pixel} position={@position} color={@label_color}>
        <%= render_slot(@inner_block, y_value) %>
      </.y_label>
      <.horizontal_line
        :if={@grid_lines}
        dimensions={@dimensions}
        y_pixel={y_pixel}
        width={@line_width}
        color={@line_color}
      />
    <% end %>
    """
  end

  attr :scale, :any, required: true
  attr :ticks, :any
  attr :step, :any

  attr :position, :atom, values: [:top, :bottom], default: :bottom

  attr :label_color, :string, default: "#18191A"

  attr :grid_lines, :boolean, default: true
  attr :line_width, :string, default: "1"
  attr :line_color, :string, default: "#F2F4F5"

  slot :inner_block, required: true

  def x_axis(assigns) do
    {scale, dimensions} = assigns.scale
    assigns = assign(assigns, dimensions: dimensions, scale: scale)

    ~H"""
    <%= for x_value <- Scale.values(@scale, scale_opts(assigns)), x_pixel = x_to_graph(x_value, @dimensions, @scale) do %>
      <.x_label dimensions={@dimensions} x_pixel={x_pixel} position={@position} color={@label_color}>
        <%= render_slot(@inner_block, x_value) %>
      </.x_label>
      <.vertical_line
        :if={@grid_lines}
        dimensions={@dimensions}
        x_pixel={x_pixel}
        width={@line_width}
        color={@line_color}
      />
    <% end %>
    """
  end

  defp scale_opts(assigns), do: Map.take(assigns, [:ticks, :step])

  attr :dataset, :any, required: true

  attr :x, :atom, default: :x, doc: "The dataset axis key to use for x values"
  attr :y, :atom, default: :y, doc: "The dataset axis key to use for y values"

  attr :width, :string, examples: ["1.5", "4"], default: "2"
  attr :line_style, :atom, values: [:solid, :dashed, :dotted], default: :solid
  attr :color, :string, default: "#FF9330"
  attr :type, :atom, values: [:line, :step_line], default: :line

  def line_plot(assigns) do
    {dataset, dimensions} = assigns.dataset

    points_fun =
      case assigns.type do
        :line -> &points/4
        :step_line -> &step_points/4
      end

    points =
      polyline_points(
        dataset,
        dimensions,
        assigns.x,
        assigns.y,
        points_fun
      )

    assigns = assign(assigns, points: points)

    ~H"""
    <polyline
      points={@points}
      fill="none"
      stroke={@color}
      stroke-width={@width}
      stroke-dasharray={stroke_dasharray(@line_style)}
    />
    """
  end

  attr :dataset, :any, required: true

  attr :x, :atom, default: :x, doc: "The dataset axis key to use for x values"
  attr :y, :atom, default: :y, doc: "The dataset axis key to use for y values"

  attr :radius, :any, examples: ["8", "24.5", :radius, {:radius, 2, 10}], default: "4"
  attr :color, :any, examples: ["red", "#FF9330", :color_axis], default: "#FF9330"

  def points_plot(assigns) do
    {dataset, dimensions} = assigns.dataset
    assigns = assign(assigns, dimensions: dimensions, dataset: dataset)

    ~H"""
    <circle
      :for={
        {x_pixel, y_pixel, datum} <-
          points(@dataset, @dimensions, @x, @y)
      }
      fill={color(@color, @dataset, datum)}
      cx={x_pixel}
      cy={y_pixel}
      r={radius(@radius, @dimensions, @dataset, datum)}
    />
    """
  end

  defp radius(radius, _dimensions, _dataset, _datum) when is_binary(radius) or is_number(radius),
    do: radius

  defp radius(key, dimensions, dataset, datum) when is_atom(key) do
    # TODO: infer radius min and max based on graph dimensions
    radius({key, 2, 20}, dimensions, dataset, datum)
  end

  defp radius({key, min, max}, _dimensions, dataset, datum) do
    # TODO: be more assertive with the key access
    Scale.convert_to_range(dataset.scales[key], datum[key], min..max) |> to_string()
  end

  defp color(color, _dataset, _datum) when is_binary(color), do: color

  defp color(key, dataset, datum) when is_atom(key) do
    # TODO: be more assertive with the key access
    ColorScale.convert_to_color(dataset.scales[key], datum[key])
  end

  attr :dataset, :any, required: true

  attr :area, :atom, default: :x, doc: "The dataset axis key to use for area"
  attr :color, :atom, default: :y, doc: "The dataset axis key to use for colors"

  def area_plot(assigns) do
    {dataset, dimensions} = assigns.dataset

    assigns =
      assign(assigns,
        dimensions: dimensions,
        dataset: dataset,
        rect_points: area_points(dataset, dimensions, assigns.area)
      )

    ~H"""
    <%= for [{x1_pixel, datum}, {x2_pixel, _datum}] <- @rect_points, rect_color = color(@color, @dataset, datum) do %>
      <rect
        :if={!is_nil(rect_color)}
        fill={rect_color}
        height={@dimensions.height - @dimensions.gutters.top - @dimensions.gutters.bottom}
        width={x2_pixel - x1_pixel}
        x={x1_pixel}
        y={@dimensions.gutters.top}
      />
    <% end %>
    """
  end

  attr :dimensions, :map, required: true
  attr :y_pixel, :float, required: true, doc: "Y pixel value for rendering this label"
  attr :position, :atom, required: true, values: [:left, :right]

  attr :color, :string, required: true
  attr :style, :string, default: "font-size: 0.75rem; line-height: 1rem"

  slot :inner_block, required: true

  defp y_label(%{position: :left} = assigns) do
    ~H"""
    <text
      x={@dimensions.gutters.left - 16}
      y={@y_pixel}
      fill={@color}
      dominant-baseline="middle"
      text-anchor="end"
      style={@style}
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
      fill={@color}
      dominant-baseline="middle"
      text-anchor="start"
      style={@style}
    >
      <%= render_slot(@inner_block) %>
    </text>
    """
  end

  attr :dimensions, :map, required: true
  attr :x_pixel, :float, required: true, doc: "X pixel value for rendering this label"
  attr :position, :atom, required: true, values: [:top, :bottom]

  attr :color, :string, required: true
  attr :style, :string, default: "font-size: 0.75rem; line-height: 1rem"

  slot :inner_block, required: true

  defp x_label(%{position: :bottom} = assigns) do
    ~H"""
    <text
      x={@x_pixel}
      y={@dimensions.height - @dimensions.gutters.bottom + 16}
      fill={@color}
      dominant-baseline="hanging"
      text-anchor="middle"
      style={@style}
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
      fill={@color}
      dominant-baseline="text-bottom"
      text-anchor="middle"
      style={@style}
    >
      <%= render_slot(@inner_block) %>
    </text>
    """
  end

  attr :dimensions, :map, required: true
  attr :y_pixel, :float, required: true
  attr :width, :string, required: true

  attr :line_style, :atom, values: [:solid, :dashed, :dotted], default: :solid
  attr :color, :string, required: true

  defp horizontal_line(assigns) do
    ~H"""
    <line
      x1={@dimensions.gutters.left}
      y1={@y_pixel}
      x2={@dimensions.width - @dimensions.gutters.right}
      y2={@y_pixel}
      stroke={@color}
      stroke-width={@width}
      stroke-dasharray={stroke_dasharray(@line_style)}
    />
    """
  end

  attr :dimensions, :map, required: true
  attr :x_pixel, :float, required: true
  attr :width, :string, required: true

  attr :line_style, :atom, values: [:solid, :dashed, :dotted], default: :solid
  attr :color, :string, required: true

  defp vertical_line(assigns) do
    ~H"""
    <line
      x1={@x_pixel}
      y1={@dimensions.gutters.top}
      x2={@x_pixel}
      y2={@dimensions.height - @dimensions.gutters.bottom}
      stroke={@color}
      stroke-width={@width}
      stroke-dasharray={stroke_dasharray(@line_style)}
    />
    """
  end

  attr :at, :any, required: true
  attr :scale, :any, required: true
  attr :width, :string, default: "1.5"

  attr :line_style, :atom, values: [:solid, :dashed, :dotted], default: :dotted
  attr :line_color, :string, default: "#18191A"
  attr :label_color, :string, default: "#18191A"
  attr :label_style, :string, default: "font-size: 0.75rem; line-height: 1rem"

  slot :inner_block, required: true

  def vertical_marker(assigns) do
    {scale, dimensions} = assigns.scale
    value = assigns.at
    x_pixel = x_to_graph(value, dimensions, scale)
    assigns = assign(assigns, dimensions: dimensions, x_pixel: x_pixel)

    ~H"""
    <line
      x1={@x_pixel}
      y1={@dimensions.gutters.top - 12}
      x2={@x_pixel}
      y2={@dimensions.height - @dimensions.gutters.bottom}
      stroke={@line_color}
      stroke-width={@width}
      stroke-dasharray={stroke_dasharray(@line_style)}
    />
    <text
      x={@x_pixel}
      y={@dimensions.gutters.top - 24}
      fill={@label_color}
      dominant-baseline="middle"
      text-anchor="middle"
      style={@label_style}
    >
      <%= render_slot(@inner_block) %>
    </text>
    """
  end

  slot :inner_block, required: true

  def legend(assigns) do
    ~H"""
    <div style="display: flex; gap: 0.5rem">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :color, :string, required: true
  attr :label, :string, required: true

  def legend_item(assigns) do
    ~H"""
    <div style="display: flex; align-items: baseline; column-gap: 0.5rem">
      <.color_bubble color={@color} />
      <p style="font-size: 0.75rem; line-height: 1rem; color: #9D9E9F;"><%= @label %></p>
    </div>
    """
  end

  attr :color, :string, required: true

  def color_bubble(assigns) do
    ~H"""
    <div style={"background-color: #{@color}; height: 0.5rem; width: 0.5rem; flex: none; border-radius: 9999px;"} />
    """
  end

  defp polyline_points(dataset, dimensions, x_key, y_key, points_fun) do
    dataset
    |> points_fun.(dimensions, x_key, y_key)
    |> Enum.map_join(" ", fn {x, y, _} -> "#{x},#{y}" end)
  end

  defp points(dataset, dimensions, x_key, y_key) do
    # FIXME: make these functions calls on `Plox.Dataset`
    x_scale = dataset.scales[x_key]
    y_scale = dataset.scales[y_key]

    for %{^x_key => x_value, ^y_key => y_value} = datum <- dataset.data do
      {x_to_graph(x_value, dimensions, x_scale), y_to_graph(y_value, dimensions, y_scale), datum}
    end
  end

  defp step_points(dataset, dimensions, x_key, y_key) do
    # FIXME: make these functions calls on `Plox.Dataset`
    x_scale = dataset.scales[x_key]
    y_scale = dataset.scales[y_key]

    dataset.data
    |> Enum.chunk_every(2, 1)
    |> Enum.flat_map(fn
      [point1, point2] ->
        [
          {x_to_graph(point1[x_key], dimensions, x_scale),
           y_to_graph(point1[y_key], dimensions, y_scale), point1},
          {x_to_graph(point2[x_key], dimensions, x_scale),
           y_to_graph(point1[y_key], dimensions, y_scale), point2}
        ]

      [%{^x_key => x_value, ^y_key => y_value} = datum] ->
        [
          {x_to_graph(x_value, dimensions, x_scale), y_to_graph(y_value, dimensions, y_scale),
           datum}
        ]
    end)
  end

  defp area_points(dataset, dimensions, key) do
    # FIXME: make these functions calls on `Plox.Dataset`
    scale = dataset.scales[key]

    dataset.data
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [point1, point2] ->
      [
        {x_to_graph(point1[key], dimensions, scale), point1},
        {x_to_graph(point2[key], dimensions, scale), point2}
      ]
    end)
  end

  defp x_to_graph(x_value, dimensions, scale) do
    Scale.convert_to_range(
      scale,
      x_value,
      dimensions.gutters.left..(dimensions.width - dimensions.gutters.right)
    )
  end

  defp y_to_graph(y_value, dimensions, scale) do
    Scale.convert_to_range(
      scale,
      y_value,
      (dimensions.height - dimensions.gutters.bottom)..dimensions.gutters.top
    )
  end

  defp stroke_dasharray(:solid), do: false
  defp stroke_dasharray(:dotted), do: "2"
  defp stroke_dasharray(:dashed), do: "6"

  defdelegate to_graph(scales_and_datasets), to: Graph, as: :new
  defdelegate date_scale(range), to: DateScale, as: :new
  defdelegate datetime_scale(first, last), to: DateTimeScale, as: :new
  defdelegate number_scale(first, last), to: NumberScale, as: :new
  defdelegate fixed_colors_scale(color_mapping), to: FixedColorsScale, as: :new
  defdelegate fixed_values_scale(values), to: FixedValuesScale, as: :new
  defdelegate dataset(data, aces), to: Dataset, as: :new
end
