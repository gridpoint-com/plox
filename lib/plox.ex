defmodule Plox do
  @moduledoc """
  Server-side rendered SVG graphing components for Phoenix and LiveView.
  """

  use Phoenix.Component

  alias Plox.Constants
  alias Plox.Dimensions
  alias Plox.Scale

  @doc """
  Entrypoint component for rendering graphs and plots.
  """
  @doc type: :component

  attr :dimensions, Dimensions, required: true
  attr :rest, :global

  slot :inner_block, required: true

  def graph(assigns) do
    ~H"""
    <div {@rest}>
      <div style={"width: #{@dimensions.width}px; height: #{@dimensions.height}px"}>
        <svg
          viewBox={"0 0 #{@dimensions.width} #{@dimensions.height}"}
          xmlns="http://www.w3.org/2000/svg"
        >
          {render_slot(@inner_block)}
        </svg>
      </div>
    </div>
    """
  end

  @doc """
  Draws a SVG `<polyline>` element connecting a series of points.
  """
  @doc type: :component

  attr :points, :any, required: true, doc: "String of coordinates (x1,y1 x2,y2...) or list of {x, y} tuples"
  attr :fill, :any, default: "none"
  attr :rest, :global, include: Constants.svg_presentation_attrs()

  def polyline(%{points: points} = assigns) when is_binary(points), do: do_polyline(assigns)

  def polyline(assigns) do
    points =
      assigns.points
      |> Enum.map(fn {x, y} -> %{x: x, y: y} end)
      |> polyline_points()

    assigns
    |> assign(points: points)
    |> do_polyline()
  end

  defp do_polyline(assigns) do
    ~H"""
    <polyline points={@points} fill={@fill} {@rest} />
    """
  end

  @doc """
  Draws a SVG `<polyline>` element connecting a series of points in the form of a stepped line.
  """
  @doc type: :component

  attr :points, :any, required: true, doc: "String of coordinates (x1,y1 x2,y2...) or list of {x, y} tuples"
  attr :fill, :any, default: "none"
  attr :rest, :global, include: Constants.svg_presentation_attrs()

  def step_polyline(%{points: points} = assigns) when is_binary(points) do
    points =
      points
      |> String.split(" ")
      |> Enum.map(fn point ->
        [x, y] = String.split(point, ",")
        %{x: String.to_integer(x), y: String.to_integer(y)}
      end)
      |> step_line_points()

    assigns
    |> assign(points: points)
    |> do_polyline()
  end

  def step_polyline(assigns) do
    points =
      assigns.points
      |> Enum.map(fn {x, y} -> %{x: x, y: y} end)
      |> step_line_points()

    assigns
    |> assign(points: points)
    |> do_polyline()
  end

  defp step_line_points(points) do
    points
    |> Enum.chunk_every(2, 1)
    |> Enum.flat_map(fn
      [point1, point2] -> [point1, %{point2 | y: point1.y}]
      [point] -> [point]
    end)
    |> polyline_points()
  end

  defp polyline_points(points), do: Enum.map_join(points, " ", &"#{&1.x},#{&1.y}")

  @doc """
  Draws a single or set of SVG `<circle>` elements.
  """
  @doc type: :component

  attr :cx, :any, required: true
  attr :cy, :any, required: true
  attr :r, :any, required: true
  attr :fill, :any, default: nil
  attr :stroke, :any, default: nil
  attr :"stroke-width", :any, default: nil
  attr :rest, :global, include: Constants.svg_presentation_attrs()

  def circle(assigns) do
    ~H"""
    <circle
      :for={
        {cx, cy, r, fill, stroke, stroke_width} <-
          values([@cx, @cy, @r, @fill, @stroke, assigns[:"stroke-width"]])
      }
      cx={cx}
      cy={cy}
      r={r}
      fill={fill}
      stroke={stroke}
      stroke-width={stroke_width}
      {@rest}
    />
    """
  end

  @doc """
  Returns a list of tuples for use in polyline or other SVG elements.

  ## Example

      iex> Plox.points(1, 2)
      [{1, 2}]

      iex> Plox.points([1, 2], [3, 4])
      [{1, 3}, {2, 4}]

      iex> dataset = %Plox.Dataset{
      ...>  data: [%{x: 10, y: 20}, %{x: 30, y: 40}],
      ...>  axes: %{x: %Plox.XAxis{}, y: %Plox.YAxis{}}
      ...>}
      iex> Plox.points([1, 2], dataset[:x])
      [{1, 10}, {2, 30}]

      iex> dataset = %Plox.Dataset{
      ...>  data: [%{x: 10, y: 20}, %{x: 30, y: 40}],
      ...>  axes: %{x: %Plox.XAxis{}, y: %Plox.YAxis{}}
      ...>}
      iex> Plox.points(dataset[:x], dataset[:y])
      [{10, 20}, {30, 40}]
  """
  def points(x, y) do
    values([x, y])
  end

  @doc """
  Returns a list of tuples for use in polyline or other SVG elements.

  ## Example

      iex> Plox.values([1, 2])
      [{1, 2}]

      iex> Plox.values([1, 2], [3, 4])
      [{1, 3}, {2, 4}]

      iex> dataset = %Plox.Dataset{
      ...>  data: [%{x: 10, y: 20}, %{x: 30, y: 40}],
      ...>  axes: %{x: %Plox.XAxis{}, y: %Plox.YAxis{}}
      ...>}
      iex> Plox.values([[1, 2], dataset[:x]])
      [{1, 10}, {2, 30}]

      iex> dataset = %Plox.Dataset{
      ...>  data: [%{x: 10, y: 20}, %{x: 30, y: 40}],
      ...>  axes: %{x: %Plox.XAxis{}, y: %Plox.YAxis{}}
      ...>}
      iex> Plox.values([dataset[:x], dataset[:y]])
      [{10, 20}, {30, 40}]
  """
  def values(data) do
    if Enum.any?(data, &Enumerable.impl_for/1) do
      data
      |> Enum.map(fn value ->
        if Enumerable.impl_for(value) do
          value
        else
          Stream.repeatedly(fn -> value end)
        end
      end)
      |> Enum.zip()
    else
      [List.to_tuple(data)]
    end
  end

  @doc """
  Returns scale values for rendering labels and grid lines.

  ## Example

      iex> scale_values(x_axis, ticks: 5)
      [~D[2023-08-01], ~D[2023-08-02], ...]
  """
  def scale_values(%{scale: scale}, opts \\ []) do
    opts = Map.new(opts)
    Scale.values(scale, opts)
  end

  @doc """
  Returns the y-coordinate for positioning elements above the graph (e.g. x-axis labels at top).
  See `Plox.Constants.default_label_gap/0` for default gap value.
  """
  def above_graph(dimensions, gap \\ Constants.default_label_gap()) do
    dimensions.margin.top - gap
  end

  @doc """
  Returns the y-coordinate for positioning elements below the graph (e.g. x-axis labels at bottom).
  See `Plox.Constants.default_label_gap/0` for default gap value.
  """
  def below_graph(dimensions, gap \\ Constants.default_label_gap()) do
    dimensions.height - dimensions.margin.bottom + gap
  end

  @doc """
  Returns the x-coordinate for positioning elements to the left of the graph (e.g. y-axis labels).
  See `Plox.Constants.default_label_gap/0` for default gap value.
  """
  def left_of_graph(dimensions, gap \\ Constants.default_label_gap()) do
    dimensions.margin.left - gap
  end

  @doc """
  Returns the x-coordinate for positioning elements to the right of the graph (e.g. y-axis labels).
  See `Plox.Constants.default_label_gap/0` for default gap value.
  """
  def right_of_graph(dimensions, gap \\ Constants.default_label_gap()) do
    dimensions.width - dimensions.margin.right + gap
  end

  @doc """
  Returns the top boundary of the graph area (for grid lines and other elements).
  """
  def graph_top(dimensions), do: dimensions.margin.top

  @doc """
  Returns the bottom boundary of the graph area (for grid lines and other elements).
  """
  def graph_bottom(dimensions), do: dimensions.height - dimensions.margin.bottom

  @doc """
  Returns the left boundary of the graph area (for grid lines and other elements).
  """
  def graph_left(dimensions), do: dimensions.margin.left

  @doc """
  Returns the right boundary of the graph area (for grid lines and other elements).
  """
  def graph_right(dimensions), do: dimensions.width - dimensions.margin.right

  # @doc """
  # Bar plot.
  # """
  # @doc type: :component

  # attr :dataset, :any, required: true

  # attr :x, :atom, default: :x, doc: "The dataset axis key to use for x values"
  # attr :y, :atom, default: :y, doc: "The dataset axis key to use for y values"

  # attr :width, :string, examples: ["1.5", "4"], default: "16"
  # attr :bar_style, :atom, values: [:round, :square], default: :round
  # attr :color, :any, examples: ["red", "#FF9330", :color_axis], default: "#FF9330"

  # attr :"phx-click", :any, default: nil
  # attr :"phx-target", :any, default: nil

  # # TODO:
  # # support for several groups of bars

  # def bar_plot(assigns) do
  #   ~H"""
  #   <%= for point <- GraphDataset.to_graph_points(@dataset, @x, @y) do %>
  #     <line
  #       phx-click={
  #         if assigns[:"phx-click"],
  #           do:
  #             JS.push(assigns[:"phx-click"],
  #               value: %{
  #                 id: point.data_point.id,
  #                 dataset_id: @dataset.id,
  #                 x_pixel: point.x,
  #                 y_pixel: point.y
  #               }
  #             )
  #       }
  #       phx-target={assigns[:"phx-target"]}
  #       style={if assigns[:"phx-click"], do: "cursor: pointer;"}
  #       x1={point.x}
  #       y1={point.y}
  #       x2={point.x}
  #       y2={
  #         @dataset.dimensions.height - @dataset.dimensions.margin.bottom -
  #           @dataset.dimensions.padding.bottom
  #       }
  #       stroke={GraphDataset.to_color(@dataset, @color, point.data_point)}
  #       stroke-width={@width}
  #       stroke-linecap={bar_style(@bar_style)}
  #     />
  #   <% end %>
  #   """
  # end

  # defp bar_style(:round), do: "round"
  # defp bar_style(:square), do: "butt"

  # @doc """
  # Tooltip.
  # """
  # @doc type: :component

  # attr :dataset, :any, required: true
  # attr :point_id, :any, required: true
  # attr :x, :atom, default: :x, doc: "The dataset axis key to use for x values"
  # attr :y, :atom, default: :y, doc: "The dataset axis key to use for y values"

  # attr :x_pixel, :any, required: true
  # attr :y_pixel, :any, required: true

  # attr :"phx-click-away", :any
  # attr :"phx-target", :any, default: nil

  # slot :inner_block, required: true

  # def tooltip(%{x_pixel: x_pixel, y_pixel: y_pixel} = assigns) do
  #   height = assigns.dataset.dimensions.height
  #   width = assigns.dataset.dimensions.width

  #   {bubble_classes_lr, caret_classes_lr} =
  #     if x_pixel < width / 2 do
  #       # left half of the graph, move caret and bubble right of point
  #       {"left: #{x_pixel + 10}px;", "left: #{x_pixel + 4}px;"}
  #     else
  #       # right half of the graph, move caret and bubble left of point
  #       {"right: #{width - x_pixel + 10}px;", "right: #{width - x_pixel + 4}px;"}
  #     end

  #   bubble_classes_tb =
  #     if y_pixel < height / 2 do
  #       # top half of the graph, move bubble up 20px
  #       "top: #{y_pixel - 20}px;"
  #     else
  #       # bottom half of the graph, move bubble below 20px
  #       "bottom: #{height - y_pixel - 20}px;"
  #     end

  #   assigns =
  #     assign(assigns,
  #       data_point: GraphDataset.get_point(assigns.dataset, assigns.point_id),
  #       bubble_classes_lr: bubble_classes_lr,
  #       caret_classes_lr: caret_classes_lr,
  #       bubble_classes_tb: bubble_classes_tb
  #     )

  #   ~H"""
  #   <div>
  #     <%!-- caret --%>
  #     <div style={[
  #       "position: absolute; z-index: 10; width: 1rem; height: 1rem; background: #4B4C4D;",
  #       "top: #{@y_pixel - 8}px; transform: rotate(45deg);",
  #       @caret_classes_lr
  #     ]} />

  #     <%!-- bubble --%>
  #     <div
  #       style={[
  #         "position: absolute; z-index: 15; padding: 1rem; border-radius: 0.75rem; width: max-content;",
  #         "background: #4B4C4D; color: #CACBCC ; font-size: 0.75rem;",
  #         "box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);",
  #         @bubble_classes_lr,
  #         @bubble_classes_tb
  #       ]}
  #       phx-click-away={assigns[:"phx-click-away"]}
  #       phx-target={assigns[:"phx-target"]}
  #     >
  #       {render_slot(@inner_block, @data_point.original)}
  #     </div>
  #   </div>
  #   """
  # end

  # @doc """
  # One-dimensional shaded areas, either horizontal or vertical.
  # """
  # @doc type: :component

  # attr :dataset, :any, required: true

  # attr :area, :atom, required: true, doc: "The dataset axis key to use for the area plots"
  # attr :color, :atom, required: true, doc: "The dataset axis key to use for colors"

  # attr :orientation, :atom, values: [:vertical, :horizontal], default: :horizontal

  # attr :"phx-click", :any, default: nil
  # attr :"phx-target", :any, default: nil

  # def area_plot(%{orientation: :horizontal} = assigns) do
  #   ~H"""
  #   <%= for [scalar1, scalar2] <- area_points(@dataset, @area, @orientation), rect_color = GraphDataset.to_color(@dataset, @color, scalar1.data_point) do %>
  #     <rect
  #       :if={!is_nil(rect_color)}
  #       fill={rect_color}
  #       height={
  #         @dataset.dimensions.height - @dataset.dimensions.margin.top -
  #           @dataset.dimensions.margin.bottom
  #       }
  #       width={scalar2.value - scalar1.value}
  #       x={scalar1.value}
  #       y={@dataset.dimensions.margin.top}
  #       phx-click={
  #         if assigns[:"phx-click"],
  #           do:
  #             JS.push(assigns[:"phx-click"],
  #               value: %{
  #                 start_area_point_id: scalar1.data_point.id,
  #                 end_area_point_id: scalar2.data_point.id,
  #                 dataset_id: @dataset.id,
  #                 x_pixel: scalar1.value + (scalar2.value - scalar1.value) / 2,
  #                 y_pixel: @dataset.dimensions.margin.top + @dataset.dimensions.height / 2
  #               }
  #             )
  #       }
  #       style={if assigns[:"phx-click"], do: "cursor: pointer;"}
  #       phx-target={assigns[:"phx-target"]}
  #     />
  #   <% end %>
  #   """
  # end

  # def area_plot(%{orientation: :vertical} = assigns) do
  #   ~H"""
  #   <%= for [scalar1, scalar2] <- area_points(@dataset, @area, @orientation), rect_color = GraphDataset.to_color(@dataset, @color, scalar1.data_point) do %>
  #     <rect
  #       :if={!is_nil(rect_color)}
  #       fill={rect_color}
  #       height={scalar1.value - scalar2.value}
  #       width={
  #         @dataset.dimensions.width - @dataset.dimensions.margin.left -
  #           @dataset.dimensions.margin.right
  #       }
  #       x={@dataset.dimensions.margin.left}
  #       y={scalar1.value - (scalar1.value - scalar2.value)}
  #       phx-click={
  #         if assigns[:"phx-click"],
  #           do:
  #             JS.push(assigns[:"phx-click"],
  #               value: %{
  #                 start_area_point_id: scalar1.data_point.id,
  #                 end_area_point_id: scalar2.data_point.id,
  #                 dataset_id: @dataset.id,
  #                 x_pixel: @dataset.dimensions.margin.left + @dataset.dimensions.width / 2,
  #                 y_pixel: scalar2.value + (scalar1.value - scalar2.value) / 2
  #               }
  #             )
  #       }
  #       style={if assigns[:"phx-click"], do: "cursor: pointer;"}
  #       phx-target={assigns[:"phx-target"]}
  #     />
  #   <% end %>
  #   """
  # end

  # defp area_points(%GraphDataset{} = graph_dataset, key, :horizontal) do
  #   graph_dataset
  #   |> GraphDataset.to_graph_xs(key)
  #   |> Enum.chunk_every(2, 1, :discard)
  # end

  # defp area_points(%GraphDataset{} = graph_dataset, key, :vertical) do
  #   graph_dataset
  #   |> GraphDataset.to_graph_ys(key)
  #   |> Enum.chunk_every(2, 1, :discard)
  # end

  # @doc """
  # Legend row.
  # """
  # @doc type: :component

  # slot :inner_block, required: true

  # def legend(assigns) do
  #   ~H"""
  #   <div style="display: flex; gap: 0.5rem">
  #     {render_slot(@inner_block)}
  #   </div>
  #   """
  # end

  # @doc """
  # Legend item.
  # """
  # @doc type: :component

  # attr :color, :string, required: true
  # attr :label, :string, required: true

  # def legend_item(assigns) do
  #   ~H"""
  #   <div style="display: flex; align-items: baseline; column-gap: 0.5rem">
  #     <.color_bubble color={@color} />
  #     <p style="font-size: 0.75rem; line-height: 1rem; color: #9D9E9F;">{@label}</p>
  #   </div>
  #   """
  # end

  # @doc """
  # A colored circle for legends.
  # """
  # @doc type: :component

  # attr :color, :string, required: true

  # def color_bubble(assigns) do
  #   ~H"""
  #   <div style={"background-color: #{@color}; height: 0.5rem; width: 0.5rem; flex: none; border-radius: 9999px;"} />
  #   """
  # end
end
