defmodule Plox do
  @moduledoc """
  TODO:
  """

  use Phoenix.Component

  alias Phoenix.LiveView.JS

  alias Plox.ColorScale
  alias Plox.Dataset
  alias Plox.DateScale
  alias Plox.DateTimeScale
  alias Plox.Dimensions
  alias Plox.FixedColorsScale
  alias Plox.FixedValuesScale
  alias Plox.Graph
  alias Plox.GraphDataset
  alias Plox.GraphScale
  alias Plox.NumberScale
  alias Plox.Scale

  attr :for, Graph, required: true

  attr :id, :string, required: true
  attr :width, :any, required: true, doc: "The total width of the rendered graph in pixels"
  attr :height, :any, required: true, doc: "The total height of the rendered graph in pixels"

  attr :margin, :any,
    default: {35, 70},
    doc: """
    The amount of space around the plotting area of the graph in which the axis labels are
    rendered. Accepts one, two, three or four values and interprets them the same was as in
    CSS.
    """

  attr :padding, :any,
    default: 0,
    doc: """
    The amount of space inside the plotting area of the graph from the edges to where plotting
    begins. Accepts one, two, three or four values and interprets them the same was as in CSS.
    """

  slot :legend
  slot :tooltips
  slot :inner_block, required: true

  def graph(assigns) do
    assigns =
      assign(assigns,
        for: nil,
        graph: Graph.put_dimensions(assigns.for, Dimensions.new(assigns))
      )

    ~H"""
    <div id={@id}>
      <div style={"display: flex; flex-direction: column; align-items: flex-end; max-width: #{@graph.dimensions.width - @graph.dimensions.margin.right}px"}>
        <.legend :for={legend <- @legend}>
          <%= render_slot(legend) %>
        </.legend>
      </div>
      <div style={"position: relative; width: #{@width}px; height: #{@height}px"}>
        <svg viewBox={"0 0 #{@width} #{@height}"} xmlns="http://www.w3.org/2000/svg">
          <%= render_slot(@inner_block, @graph) %>
        </svg>
        <%= for tooltip <- @tooltips do %>
          <%= render_slot(tooltip, @graph) %>
        <% end %>
      </div>
    </div>
    """
  end

  attr :scale, :any, required: true
  attr :ticks, :any
  attr :step, :any

  attr :position, :atom, values: [:left, :right], default: :left

  attr :label_color, :string, default: "#18191A"
  attr :label_rotation, :integer, default: nil

  attr :grid_lines, :boolean, default: true
  attr :line_width, :string, default: "1"
  attr :line_color, :string, default: "#F2F4F5"

  slot :inner_block, required: true

  def y_axis(assigns) do
    ~H"""
    <%= for y_value <- GraphScale.values(@scale, scale_opts(assigns)), y_pixel = GraphScale.to_graph_y(@scale, y_value) do %>
      <.y_label
        dimensions={@scale.dimensions}
        y_pixel={y_pixel}
        position={@position}
        color={@label_color}
        rotation={@label_rotation}
      >
        <%= render_slot(@inner_block, y_value) %>
      </.y_label>
      <.horizontal_line
        :if={@grid_lines}
        dimensions={@scale.dimensions}
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
  attr :label_rotation, :integer, default: nil

  attr :grid_lines, :boolean, default: true
  attr :line_width, :string, default: "1"
  attr :line_color, :string, default: "#F2F4F5"

  slot :inner_block, required: true

  def x_axis(assigns) do
    ~H"""
    <%= for x_value <- GraphScale.values(@scale, scale_opts(assigns)), x_pixel = GraphScale.to_graph_x(@scale, x_value) do %>
      <.x_label
        dimensions={@scale.dimensions}
        x_pixel={x_pixel}
        position={@position}
        color={@label_color}
        rotation={@label_rotation}
      >
        <%= render_slot(@inner_block, x_value) %>
      </.x_label>
      <.vertical_line
        :if={@grid_lines}
        dimensions={@scale.dimensions}
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

  def line_plot(%{type: :line} = assigns) do
    ~H"""
    <polyline
      points={@dataset |> GraphDataset.to_graph_points(@x, @y) |> polyline_points()}
      fill="none"
      stroke={@color}
      stroke-width={@width}
      stroke-dasharray={stroke_dasharray(@line_style)}
    />
    """
  end

  def line_plot(%{type: :step_line} = assigns) do
    ~H"""
    <polyline
      points={@dataset |> step_points(@x, @y) |> polyline_points()}
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
  attr :phx_click_event, :any, default: nil
  attr :phx_target, :any, default: nil

  def points_plot(assigns) do
    ~H"""
    <circle
      :for={{x_pixel, y_pixel, datum} <- GraphDataset.to_graph_points(@dataset, @x, @y)}
      phx-click={
        if @phx_click_event,
          do: JS.push(@phx_click_event, value: %{id: datum.id, dataset_id: @dataset.id})
      }
      phx-target={@phx_target}
      fill={color(@color, @dataset, datum)}
      cx={x_pixel}
      cy={y_pixel}
      r={radius(@radius, @dataset, datum)}
      style="cursor: pointer;"
    />
    """
  end

  attr :dataset, :any, required: true

  attr :x, :atom, default: :x, doc: "The dataset axis key to use for x values"
  attr :y, :atom, default: :y, doc: "The dataset axis key to use for y values"

  attr :width, :string, examples: ["1.5", "4"], default: "16"
  attr :bar_style, :atom, values: [:round, :square], default: :round
  attr :color, :any, examples: ["red", "#FF9330", :color_axis], default: "#FF9330"

  attr :phx_click_event, :any, default: nil
  attr :phx_target, :any, default: nil

  # TODO:
  # support for several groups of bars

  def bar_plot(assigns) do
    ~H"""
    <%= for {x_pixel, y_pixel, datum} <- GraphDataset.to_graph_points(@dataset, @x, @y) do %>
      <line
        phx-click={
          if @phx_click_event,
            do: JS.push(@phx_click_event, value: %{id: datum.id, dataset_id: @dataset.id})
        }
        x1={x_pixel}
        y1={y_pixel}
        x2={x_pixel}
        phx-target={@phx_target}
        y2={
          @dataset.dimensions.height - @dataset.dimensions.margin.bottom -
            @dataset.dimensions.padding.bottom
        }
        stroke={color(@color, @dataset, datum)}
        stroke-width={@width}
        stroke-linecap={bar_style(@bar_style)}
        style="cursor: pointer;"
      />
    <% end %>
    """
  end

  attr :dataset, :any, required: true
  attr :point_id, :any, required: true
  attr :phx_click_away_event, :any

  attr :x, :atom, default: :x, doc: "The dataset axis key to use for x values"
  attr :y, :atom, default: :y, doc: "The dataset axis key to use for y values"

  slot :inner_block, required: true

  def tooltip(assigns) do
    {x_pixel, y_pixel, datum} =
      GraphDataset.to_graph_point(assigns.dataset, assigns.x, assigns.y, assigns.point_id)

    assigns =
      assign(assigns, x_pixel: x_pixel, y_pixel: y_pixel, datum: datum)

    ~H"""
    <div
      style={[
        "position: absolute; padding: 1rem; font-size: 0.75rem; background: #4B4C4D; color: #CACBCC; z-index: 10; border-radius: 0.75rem; transform: translate(-50%);",
        "left: #{@x_pixel}px; bottom: #{@dataset.dimensions.height - @y_pixel + 12}px;",
        "box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);"
      ]}
      phx-click-away={@phx_click_away_event}
    >
      <%= render_slot(@inner_block, @datum) %>
      <div style="transform: translate(-50%) rotate(45deg); position: absolute; left: 50%; bottom: -0.5rem; width: 1rem; height: 1rem; z-index: -10; background: #4B4C4D" />
    </div>
    """
  end

  defp radius(radius, _graph_dataset, _datum) when is_binary(radius) or is_number(radius),
    do: radius

  defp radius(key, graph_dataset, datum) when is_atom(key) do
    # TODO: infer radius min and max based on graph dimensions
    radius({key, 2, 20}, graph_dataset, datum)
  end

  defp radius({key, min, max}, graph_dataset, datum) do
    # TODO: be more assertive with the key access
    # FIXME: if the scale is backwards, the min..max needs to be reversed
    Scale.convert_to_range(graph_dataset.dataset.scales[key], datum[key], min..max) |> to_string()
  end

  defp color(color, _graph_dataset, _datum) when is_binary(color), do: color

  defp color(key, graph_dataset, datum) when is_atom(key) do
    # TODO: be more assertive with the key access
    # FIXME:
    ColorScale.convert_to_color(graph_dataset.dataset.scales[key], datum[key])
  end

  attr :dataset, :any, required: true

  attr :area, :atom, default: :x, doc: "The dataset axis key to use for area"
  attr :color, :atom, default: :y, doc: "The dataset axis key to use for colors"

  def area_plot(assigns) do
    ~H"""
    <%= for [{x1_pixel, datum}, {x2_pixel, _datum}] <- area_points(@dataset, @area), rect_color = color(@color, @dataset, datum) do %>
      <rect
        :if={!is_nil(rect_color)}
        fill={rect_color}
        height={
          @dataset.dimensions.height - @dataset.dimensions.margin.top -
            @dataset.dimensions.margin.bottom
        }
        width={x2_pixel - x1_pixel}
        x={x1_pixel}
        y={@dataset.dimensions.margin.top}
      />
    <% end %>
    """
  end

  attr :dimensions, :map, required: true
  attr :y_pixel, :float, required: true, doc: "Y pixel value for rendering this label"
  attr :position, :atom, required: true, values: [:left, :right]

  attr :color, :string, required: true
  attr :style, :string, default: "font-size: 0.75rem; line-height: 1rem"
  attr :rotation, :integer, default: nil

  slot :inner_block, required: true

  defp y_label(%{position: :left} = assigns) do
    ~H"""
    <text
      x={@dimensions.margin.left - 16}
      y={@y_pixel}
      fill={@color}
      dominant-baseline="middle"
      text-anchor="end"
      style={@style}
      transform={
        if @rotation,
          do: "rotate(#{@rotation}, #{@dimensions.margin.left - 16}, #{@y_pixel})"
      }
    >
      <%= render_slot(@inner_block) %>
    </text>
    """
  end

  defp y_label(%{position: :right} = assigns) do
    ~H"""
    <text
      x={@dimensions.width - @dimensions.margin.right + 16}
      y={@y_pixel}
      fill={@color}
      dominant-baseline="middle"
      text-anchor="start"
      style={@style}
      transform={
        if @rotation,
          do:
            "rotate(#{@rotation}, #{@dimensions.width - @dimensions.margin.right + 16}, #{@y_pixel})"
      }
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
  attr :rotation, :integer, default: nil

  slot :inner_block, required: true

  defp x_label(%{position: :bottom} = assigns) do
    ~H"""
    <text
      x={@x_pixel}
      y={@dimensions.height - @dimensions.margin.bottom + 16}
      fill={@color}
      dominant-baseline="hanging"
      text-anchor="middle"
      style={@style}
      transform={
        if @rotation,
          do:
            "rotate(#{@rotation}, #{@x_pixel}, #{@dimensions.height - @dimensions.margin.bottom + 16})"
      }
    >
      <%= render_slot(@inner_block) %>
    </text>
    """
  end

  defp x_label(%{position: :top} = assigns) do
    ~H"""
    <text
      x={@x_pixel}
      y={@dimensions.margin.bottom - 16}
      fill={@color}
      dominant-baseline="text-bottom"
      text-anchor="middle"
      style={@style}
      transform={
        if @rotation,
          do: "rotate(#{@rotation}, #{@x_pixel}, #{@dimensions.margin.bottom - 16})"
      }
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
      x1={@dimensions.margin.left}
      y1={@y_pixel}
      x2={@dimensions.width - @dimensions.margin.right}
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
      y1={@dimensions.margin.top}
      x2={@x_pixel}
      y2={@dimensions.height - @dimensions.margin.bottom}
      stroke={@color}
      stroke-width={@width}
      stroke-dasharray={stroke_dasharray(@line_style)}
    />
    """
  end

  attr :at, :any, required: true
  attr :scale, :any, required: true
  attr :width, :string, default: "1.5"
  attr :orientation, :atom, values: [:vertical, :horizontal], default: :vertical

  attr :line_style, :atom, values: [:solid, :dashed, :dotted], default: :dotted
  attr :line_color, :string, default: "#18191A"
  attr :label_color, :string, default: "#18191A"
  attr :label_style, :string, default: "font-size: 0.75rem; line-height: 1rem"
  attr :label_rotation, :integer, default: nil

  slot :inner_block, required: true

  def marker(%{orientation: :vertical} = assigns) do
    x_pixel = GraphScale.to_graph_x(assigns.scale, assigns.at)
    assigns = assign(assigns, dimensions: assigns.scale.dimensions, x_pixel: x_pixel)

    ~H"""
    <line
      x1={@x_pixel}
      y1={@dimensions.margin.top - 12}
      x2={@x_pixel}
      y2={@dimensions.height - @dimensions.margin.bottom}
      stroke={@line_color}
      stroke-width={@width}
      stroke-dasharray={stroke_dasharray(@line_style)}
    />
    <text
      x={@x_pixel}
      y={@dimensions.margin.top - 24}
      fill={@label_color}
      dominant-baseline="middle"
      text-anchor="middle"
      style={@label_style}
      transform={
        if @label_rotation,
          do: "rotate(#{@label_rotation}, #{@x_pixel}, #{@dimensions.margin.top - 24})"
      }
    >
      <%= render_slot(@inner_block) %>
    </text>
    """
  end

  def marker(%{orientation: :horizontal} = assigns) do
    y_pixel = GraphScale.to_graph_y(assigns.scale, assigns.at)
    assigns = assign(assigns, dimensions: assigns.scale.dimensions, y_pixel: y_pixel)

    ~H"""
    <line
      x1={@dimensions.margin.left - 12}
      y1={@y_pixel}
      x2={@dimensions.width - @dimensions.margin.right}
      y2={@y_pixel}
      stroke={@line_color}
      stroke-width={@width}
      stroke-dasharray={stroke_dasharray(@line_style)}
    />
    <text
      x={@dimensions.margin.left - 24}
      y={@y_pixel}
      fill={@label_color}
      dominant-baseline="middle"
      text-anchor="middle"
      style={@label_style}
      transform={
        if @label_rotation,
          do: "rotate(#{@label_rotation}, #{@dimensions.margin.left - 24}, #{@y_pixel})"
      }
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

  defp polyline_points(points), do: Enum.map_join(points, " ", fn {x, y, _} -> "#{x},#{y}" end)

  defp step_points(%GraphDataset{} = graph_dataset, x_key, y_key) do
    x_scale = GraphDataset.get_scale!(graph_dataset, x_key)
    y_scale = GraphDataset.get_scale!(graph_dataset, y_key)

    graph_dataset.dataset.data
    |> Enum.chunk_every(2, 1)
    |> Enum.flat_map(fn
      [point1, point2] ->
        [
          {GraphScale.to_graph_x(x_scale, point1[x_key]),
           GraphScale.to_graph_y(y_scale, point1[y_key]), point1},
          {GraphScale.to_graph_x(x_scale, point2[x_key]),
           GraphScale.to_graph_y(y_scale, point1[y_key]), point2}
        ]

      [%{^x_key => x_value, ^y_key => y_value} = datum] ->
        [
          {GraphScale.to_graph_x(x_scale, x_value), GraphScale.to_graph_y(y_scale, y_value),
           datum}
        ]
    end)
  end

  defp area_points(%GraphDataset{} = graph_dataset, key) do
    scale = GraphDataset.get_scale!(graph_dataset, key)

    graph_dataset.dataset.data
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [point1, point2] ->
      [
        {GraphScale.to_graph_x(scale, point1[key]), point1},
        {GraphScale.to_graph_x(scale, point2[key]), point2}
      ]
    end)
  end

  defp bar_style(:round), do: "round"
  defp bar_style(:square), do: "butt"

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
