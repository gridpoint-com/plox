defmodule Plox do
  @moduledoc """
  TODO:
  """

  use Phoenix.Component

  alias Phoenix.LiveView.JS
  alias Plox.Axis
  alias Plox.Dataset
  alias Plox.DateScale
  alias Plox.DateTimeScale
  alias Plox.Dimensions
  alias Plox.FixedColorsScale
  alias Plox.FixedValuesScale
  alias Plox.GraphDataset
  alias Plox.GraphScale
  alias Plox.NumberScale
  alias Plox.Scale
  alias Plox.XAxis
  alias Plox.YAxis

  # copied from SVG spec: https://svgwg.org/svg2-draft/styling.html#TermPresentationAttribute
  @svg_presentation_globals ~w(alignment-baseline baseline-shift clip-path clip-rule color color-interpolation color-interpolation-filters cursor direction display dominant-baseline fill-opacity fill-rule filter flood-color flood-opacity font-family font-size font-size-adjust font-stretch font-style font-variant font-weight glyph-orientation-horizontal glyph-orientation-vertical image-rendering letter-spacing lighting-color marker-end marker-mid marker-start mask mask-type opacity overflow paint-order pointer-events shape-rendering stop-color stop-opacity stroke stroke-dasharray stroke-dashoffset stroke-linecap stroke-linejoin stroke-miterlimit stroke-opacity stroke-width text-anchor text-decoration text-overflow text-rendering transform-origin unicode-bidi vector-effect visibility white-space word-spacing writing-mode)

  @doc """
  Entrypoint component for rendering graphs and plots.
  """
  @doc type: :component

  attr :dimensions, Dimensions, required: true
  # FIXME:
  attr :rest, :global

  slot :legend
  slot :tooltips
  slot :inner_block, required: true

  def graph(assigns) do
    # assigns =
    #   assign(assigns,
    #     for: nil,
    #     graph: Graph.put_dimensions(assigns.for, Dimensions.new(assigns))
    #   )

    ~H"""
    <div {@rest}>
      <%!-- <div style={"display: flex; flex-direction: column; align-items: flex-end; max-width: #{@graph.width - @graph.margin.right}px"}>
        <.legend :for={legend <- @legend}>
          <%= render_slot(legend) %>
        </.legend>
      </div> --%>
      <div style={"position: relative; width: #{@dimensions.width}px; height: #{@dimensions.height}px"}>
        <svg
          viewBox={"0 0 #{@dimensions.width} #{@dimensions.height}"}
          xmlns="http://www.w3.org/2000/svg"
        >
          <%= render_slot(@inner_block) %>
        </svg>
        <%!-- <%= for tooltip <- @tooltips do %>
          <%= render_slot(tooltip) %>
        <% end %> --%>
      </div>
    </div>
    """
  end

  @doc """
  X-axis labels along the bottom or top of the graph.

  See `x_axis_label/1` for more details on the accepeted attributes.
  """
  @doc type: :component

  attr :axis, XAxis, required: true
  attr :ticks, :any
  attr :step, :any
  attr :rest, :global, include: ~w(gap rotation position) ++ @svg_presentation_globals

  slot :inner_block, required: true

  def x_axis_labels(assigns) do
    ~H"""
    <%= for value <- Scale.values(@axis.scale, Map.take(assigns, [:ticks, :step])) do %>
      <.x_axis_label axis={@axis} value={value} {@rest}>
        <%= render_slot(@inner_block, value) %>
      </.x_axis_label>
    <% end %>
    """
  end

  @doc """
  An X-axis label at the bottom or top of the graph.
  """
  @doc type: :component

  attr :axis, XAxis, required: true
  attr :value, :any, required: true
  attr :position, :atom, values: [:top, :bottom], default: :bottom
  attr :gap, :integer, default: 16
  attr :rotation, :integer, default: nil
  attr :"dominant-baseline", :any, default: nil
  attr :"text-anchor", :any, default: nil
  attr :rest, :global, include: @svg_presentation_globals

  slot :inner_block, required: true

  def x_axis_label(%{position: :bottom} = assigns) do
    ~H"""
    <text
      x={x = Axis.to_graph(@axis, @value)}
      y={@axis.dimensions.height - @axis.dimensions.margin.bottom + @gap}
      dominant-baseline={assigns[:"dominant-baseline"] || "hanging"}
      text-anchor={assigns[:"text-anchor"] || "middle"}
      transform={
        if @rotation,
          do:
            "rotate(#{@rotation}, #{x}, #{@axis.dimensions.height - @axis.dimensions.margin.bottom + @gap})"
      }
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </text>
    """
  end

  def x_axis_label(%{position: :top} = assigns) do
    ~H"""
    <text
      x={x = Axis.to_graph(@axis, @value)}
      y={@axis.dimensions.margin.bottom - @gap}
      dominant-baseline={assigns[:"dominant-baseline"] || "text-bottom"}
      text-anchor={assigns[:"text-anchor"] || "middle"}
      transform={
        if @rotation,
          do: "rotate(#{@rotation}, #{x}, #{@axis.dimensions.margin.bottom - @gap})"
      }
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </text>
    """
  end

  @doc """
  Y-axis labels along the left or right side of the graph.

  See `y_axis_label/1` for more details on the accepeted attributes.
  """
  @doc type: :component

  attr :axis, YAxis, required: true
  attr :ticks, :any
  attr :step, :any
  attr :rest, :global, include: ~w(gap rotation position) ++ @svg_presentation_globals

  slot :inner_block, required: true

  def y_axis_labels(assigns) do
    ~H"""
    <%= for value <- Scale.values(@axis.scale, Map.take(assigns, [:ticks, :step])) do %>
      <.y_axis_label axis={@axis} value={value} {@rest}>
        <%= render_slot(@inner_block, value) %>
      </.y_axis_label>
    <% end %>
    """
  end

  @doc """
  A Y-axis label at the left or right side of the graph.
  """
  @doc type: :component

  attr :axis, YAxis, required: true
  attr :value, :any, required: true
  attr :position, :atom, values: [:left, :right], default: :left
  attr :gap, :integer, default: 16
  attr :rotation, :integer, default: nil
  attr :"dominant-baseline", :any, default: nil
  attr :"text-anchor", :any, default: nil
  attr :rest, :global, include: @svg_presentation_globals

  slot :inner_block, required: true

  def y_axis_label(%{position: :left} = assigns) do
    ~H"""
    <text
      x={@axis.dimensions.margin.left - @gap}
      y={y = Axis.to_graph(@axis, @value)}
      dominant-baseline={assigns[:"dominant-baseline"] || "middle"}
      text-anchor={assigns[:"text-anchor"] || "end"}
      transform={
        if @rotation,
          do: "rotate(#{@rotation}, #{@axis.dimensions.margin.left - @gap}, #{y})"
      }
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </text>
    """
  end

  def y_axis_label(%{position: :right} = assigns) do
    ~H"""
    <text
      x={@axis.dimensions.width - @axis.dimensions.margin.right + @gap}
      y={y = Axis.to_graph(@axis, @value)}
      dominant-baseline={assigns[:"dominant-baseline"] || "middle"}
      text-anchor={assigns[:"text-anchor"] || "start"}
      transform={
        if @rotation,
          do:
            "rotate(#{@rotation}, #{@axis.dimensions.width - @axis.dimensions.margin.right + @gap}, #{y})"
      }
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </text>
    """
  end

  @doc """
  X-axis grid lines.
  """
  @doc type: :component

  attr :axis, XAxis, required: true
  attr :ticks, :any
  attr :step, :any
  attr :rest, :global, include: @svg_presentation_globals

  def x_axis_grid_lines(assigns) do
    ~H"""
    <%= for value <- Scale.values(@axis.scale, Map.take(assigns, [:ticks, :step])) do %>
      <.x_axis_grid_line axis={@axis} value={value} {@rest} />
    <% end %>
    """
  end

  @doc """
  A single X-axis grid line.
  """
  @doc type: :component

  attr :axis, XAxis, required: true
  attr :value, :any, required: true
  attr :top_overdraw, :integer, default: 0
  attr :bottom_overdraw, :integer, default: 0
  attr :rest, :global, include: @svg_presentation_globals

  def x_axis_grid_line(assigns) do
    ~H"""
    <line
      x1={x = Axis.to_graph(@axis, @value)}
      y1={@axis.dimensions.margin.top - @top_overdraw}
      x2={x}
      y2={@axis.dimensions.height - @axis.dimensions.margin.bottom + @bottom_overdraw}
      {@rest}
    />
    """
  end

  @doc """
  Y-axis grid lines.
  """
  @doc type: :component

  attr :axis, YAxis, required: true
  attr :ticks, :any
  attr :step, :any
  attr :rest, :global, include: @svg_presentation_globals

  def y_axis_grid_lines(assigns) do
    ~H"""
    <%= for value <- Scale.values(@axis.scale, Map.take(assigns, [:ticks, :step])) do %>
      <.y_axis_grid_line axis={@axis} value={value} {@rest} />
    <% end %>
    """
  end

  @doc """
  A single Y-axis grid line.
  """
  @doc type: :component

  attr :axis, YAxis, required: true
  attr :value, :any, required: true
  attr :rest, :global, include: @svg_presentation_globals

  def y_axis_grid_line(assigns) do
    ~H"""
    <line
      x1={@axis.dimensions.margin.left}
      y1={y = Axis.to_graph(@axis, @value)}
      x2={@axis.dimensions.width - @axis.dimensions.margin.right}
      y2={y}
      {@rest}
    />
    """
  end

  @doc """
  A connected line plot.
  """
  @doc type: :component

  attr :dataset, Dataset, required: true

  attr :x, :atom, default: :x, doc: "The dataset axis key to use for x values"
  attr :y, :atom, default: :y, doc: "The dataset axis key to use for y values"
  attr :fill, :any, default: "none"
  attr :rest, :global, include: @svg_presentation_globals

  def line_plot(assigns) do
    ~H"""
    <polyline points={line_points(@dataset, @x, @y)} fill={@fill} {@rest} />
    """
  end

  defp line_points(dataset, x_key, y_key) do
    dataset.data
    |> Enum.map(fn data_point -> %{x: data_point.graph[x_key], y: data_point.graph[y_key]} end)
    |> polyline_points()
  end

  @doc """
  A connected step line plot.
  """
  @doc type: :component

  attr :dataset, Dataset, required: true

  attr :x, :atom, default: :x, doc: "The dataset axis key to use for x values"
  attr :y, :atom, default: :y, doc: "The dataset axis key to use for y values"
  attr :fill, :any, default: "none"
  attr :rest, :global, include: @svg_presentation_globals

  def step_line_plot(assigns) do
    ~H"""
    <polyline points={step_line_points(@dataset, @x, @y)} fill={@fill} {@rest} />
    """
  end

  defp step_line_points(dataset, x_key, y_key) do
    dataset.data
    |> Enum.map(fn data_point -> %{x: data_point.graph[x_key], y: data_point.graph[y_key]} end)
    |> Enum.chunk_every(2, 1)
    |> Enum.flat_map(fn
      [point1, point2] -> [point1, %{point2 | y: point1.y}]
      [point] -> [point]
    end)
    |> polyline_points()
  end

  defp polyline_points(points), do: Enum.map_join(points, " ", &"#{&1.x},#{&1.y}")

  @doc """
  Points plot.
  """
  @doc type: :component

  attr :dataset, :any, required: true

  attr :x, :atom, default: :x, doc: "The dataset axis key to use for x values"
  attr :y, :atom, default: :y, doc: "The dataset axis key to use for y values"

  attr :r, :any, examples: ["8", "24.5", :radius_axis], default: "4"
  attr :fill, :any, examples: ["red", "#FF9330", :color_axis], default: nil
  attr :rest, :global, include: @svg_presentation_globals
  # attr :"phx-click", :any, default: nil
  # attr :"phx-target", :any, default: nil

  def points_plot(assigns) do
    ~H"""
    <circle
      :for={data_point <- @dataset.data}
      fill={maybe_graph(@fill, data_point)}
      cx={data_point.graph[@x]}
      cy={data_point.graph[@y]}
      r={maybe_graph(@r, data_point)}
      {@rest}
    />
    """
  end

  defp maybe_graph(assign, data_point) when is_atom(assign), do: data_point.graph[assign]
  defp maybe_graph(assign, _data_point), do: assign

  @doc """
  Bar plot.
  """
  @doc type: :component

  attr :dataset, :any, required: true

  attr :x, :atom, default: :x, doc: "The dataset axis key to use for x values"
  attr :y, :atom, default: :y, doc: "The dataset axis key to use for y values"

  attr :width, :string, examples: ["1.5", "4"], default: "16"
  attr :bar_style, :atom, values: [:round, :square], default: :round
  attr :color, :any, examples: ["red", "#FF9330", :color_axis], default: "#FF9330"

  attr :"phx-click", :any, default: nil
  attr :"phx-target", :any, default: nil

  # TODO:
  # support for several groups of bars

  def bar_plot(assigns) do
    ~H"""
    <%= for point <- GraphDataset.to_graph_points(@dataset, @x, @y) do %>
      <line
        phx-click={
          if assigns[:"phx-click"],
            do:
              JS.push(assigns[:"phx-click"],
                value: %{
                  id: point.data_point.id,
                  dataset_id: @dataset.id,
                  x_pixel: point.x,
                  y_pixel: point.y
                }
              )
        }
        phx-target={assigns[:"phx-target"]}
        style={if assigns[:"phx-click"], do: "cursor: pointer;"}
        x1={point.x}
        y1={point.y}
        x2={point.x}
        y2={
          @dataset.dimensions.height - @dataset.dimensions.margin.bottom -
            @dataset.dimensions.padding.bottom
        }
        stroke={GraphDataset.to_color(@dataset, @color, point.data_point)}
        stroke-width={@width}
        stroke-linecap={bar_style(@bar_style)}
      />
    <% end %>
    """
  end

  defp bar_style(:round), do: "round"
  defp bar_style(:square), do: "butt"

  @doc """
  Tooltip.
  """
  @doc type: :component

  attr :dataset, :any, required: true
  attr :point_id, :any, required: true
  attr :x, :atom, default: :x, doc: "The dataset axis key to use for x values"
  attr :y, :atom, default: :y, doc: "The dataset axis key to use for y values"

  attr :x_pixel, :any, required: true
  attr :y_pixel, :any, required: true

  attr :"phx-click-away", :any
  attr :"phx-target", :any, default: nil

  slot :inner_block, required: true

  def tooltip(assigns) do
    assigns =
      assign(assigns, data_point: GraphDataset.get_point(assigns.dataset, assigns.point_id))

    ~H"""
    <div
      style={[
        "position: absolute; padding: 1rem; font-size: 0.75rem; background: #4B4C4D; color: #CACBCC; z-index: 10; border-radius: 0.75rem; transform: translate(-50%);",
        "left: #{@x_pixel}px; bottom: #{@dataset.dimensions.height - @y_pixel + 12}px;",
        "box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);"
      ]}
      phx-click-away={assigns[:"phx-click-away"]}
      phx-target={assigns[:"phx-target"]}
    >
      <%= render_slot(@inner_block, @data_point.original) %>
      <div style="transform: translate(-50%) rotate(45deg); position: absolute; left: 50%; bottom: -0.5rem; width: 1rem; height: 1rem; z-index: -10; background: #4B4C4D" />
    </div>
    """
  end

  @doc """
  One-dimensional shaded areas, either horizontal or vertical.
  """
  @doc type: :component

  attr :dataset, :any, required: true

  attr :area, :atom, required: true, doc: "The dataset axis key to use for the area plots"
  attr :color, :atom, required: true, doc: "The dataset axis key to use for colors"

  attr :orientation, :atom, values: [:vertical, :horizontal], default: :horizontal

  attr :"phx-click", :any, default: nil
  attr :"phx-target", :any, default: nil

  def area_plot(%{orientation: :horizontal} = assigns) do
    ~H"""
    <%= for [scalar1, scalar2] <- area_points(@dataset, @area, @orientation), rect_color = GraphDataset.to_color(@dataset, @color, scalar1.data_point) do %>
      <rect
        :if={!is_nil(rect_color)}
        fill={rect_color}
        height={
          @dataset.dimensions.height - @dataset.dimensions.margin.top -
            @dataset.dimensions.margin.bottom
        }
        width={scalar2.value - scalar1.value}
        x={scalar1.value}
        y={@dataset.dimensions.margin.top}
        phx-click={
          if assigns[:"phx-click"],
            do:
              JS.push(assigns[:"phx-click"],
                value: %{
                  start_area_point_id: scalar1.data_point.id,
                  end_area_point_id: scalar2.data_point.id,
                  dataset_id: @dataset.id,
                  x_pixel: scalar1.value + (scalar2.value - scalar1.value) / 2,
                  y_pixel: @dataset.dimensions.margin.top + @dataset.dimensions.height / 2
                }
              )
        }
        style={if assigns[:"phx-click"], do: "cursor: pointer;"}
        phx-target={assigns[:"phx-target"]}
      />
    <% end %>
    """
  end

  def area_plot(%{orientation: :vertical} = assigns) do
    ~H"""
    <%= for [scalar1, scalar2] <- area_points(@dataset, @area, @orientation), rect_color = GraphDataset.to_color(@dataset, @color, scalar1.data_point) do %>
      <rect
        :if={!is_nil(rect_color)}
        fill={rect_color}
        height={scalar1.value - scalar2.value}
        width={
          @dataset.dimensions.width - @dataset.dimensions.margin.left -
            @dataset.dimensions.margin.right
        }
        x={@dataset.dimensions.margin.left}
        y={scalar1.value - (scalar1.value - scalar2.value)}
        phx-click={
          if assigns[:"phx-click"],
            do:
              JS.push(assigns[:"phx-click"],
                value: %{
                  start_area_point_id: scalar1.data_point.id,
                  end_area_point_id: scalar2.data_point.id,
                  dataset_id: @dataset.id,
                  x_pixel: @dataset.dimensions.margin.left + @dataset.dimensions.width / 2,
                  y_pixel: scalar2.value + (scalar1.value - scalar2.value) / 2
                }
              )
        }
        style={if assigns[:"phx-click"], do: "cursor: pointer;"}
        phx-target={assigns[:"phx-target"]}
      />
    <% end %>
    """
  end

  defp area_points(%GraphDataset{} = graph_dataset, key, :horizontal) do
    graph_dataset
    |> GraphDataset.to_graph_xs(key)
    |> Enum.chunk_every(2, 1, :discard)
  end

  defp area_points(%GraphDataset{} = graph_dataset, key, :vertical) do
    graph_dataset
    |> GraphDataset.to_graph_ys(key)
    |> Enum.chunk_every(2, 1, :discard)
  end

  @doc """
  A horizontal or vertical marker line with a label.
  """
  @doc type: :component

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

  @doc """
  A horizontal or vertical marker line with a label.
  """
  @doc type: :component

  attr :axis, XAxis, required: true
  attr :value, :any, required: true

  attr :width, :string, default: "1.5"
  attr :orientation, :atom, values: [:vertical, :horizontal], default: :vertical

  attr :line_style, :atom, values: [:solid, :dashed, :dotted], default: :dotted
  attr :line_color, :string, default: "#18191A"
  attr :label_color, :string, default: "#18191A"
  attr :label_style, :string, default: "font-size: 0.75rem; line-height: 1rem"
  attr :label_rotation, :integer, default: nil

  slot :inner_block, required: true

  def x_marker(assigns) do
    ~H"""
    <line
      x1={x = Axis.to_graph(@axis, @value)}
      y1={@axis.dimensions.margin.top - 12}
      x2={x}
      y2={@axis.dimensions.height - @axis.dimensions.margin.bottom}
      stroke={@line_color}
      stroke-width={@width}
      stroke-dasharray={stroke_dasharray(@line_style)}
    />
    <text
      x={x}
      y={@axis.dimensions.margin.top - 24}
      fill={@label_color}
      dominant-baseline="middle"
      text-anchor="middle"
      style={@label_style}
      transform={
        if @label_rotation,
          do: "rotate(#{@label_rotation}, #{x}, #{@axis.dimensions.margin.top - 24})"
      }
    >
      <%= render_slot(@inner_block) %>
    </text>
    """
  end

  @doc """
  Legend row.
  """
  @doc type: :component

  slot :inner_block, required: true

  def legend(assigns) do
    ~H"""
    <div style="display: flex; gap: 0.5rem">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Legend item.
  """
  @doc type: :component

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

  @doc """
  A colored circle for legends.
  """
  @doc type: :component

  attr :color, :string, required: true

  def color_bubble(assigns) do
    ~H"""
    <div style={"background-color: #{@color}; height: 0.5rem; width: 0.5rem; flex: none; border-radius: 9999px;"} />
    """
  end

  defp stroke_dasharray(:solid), do: false
  defp stroke_dasharray(:dotted), do: "2"
  defp stroke_dasharray(:dashed), do: "6"

  # def date_scale(graph, range), do: GraphScale.new(graph, DateScale.new(range))

  # def number_scale(graph, first, last), do: GraphScale.new(graph, NumberScale.new(first, last))

  # def dataset(data, axes), do: Dataset.new(data, axes)

  # defdelegate graph(width, height, opts \\ []), to: Graph, as: :new
  # # defdelegate date_scale(range), to: DateScale, as: :new
  # defdelegate datetime_scale(first, last), to: DateTimeScale, as: :new
  # # defdelegate number_scale(first, last), to: NumberScale, as: :new
  # defdelegate fixed_colors_scale(color_mapping), to: FixedColorsScale, as: :new
  # defdelegate fixed_values_scale(values), to: FixedValuesScale, as: :new
  # # defdelegate dataset(data, aces), to: Dataset, as: :new
end
