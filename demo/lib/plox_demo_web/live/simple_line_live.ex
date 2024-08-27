defmodule PloxDemoWeb.SimpleLineLive do
  @moduledoc """
  LiveView displaying the "Simple Line" example.
  """
  use PloxDemoWeb, :live_view

  import Plox
  import PloxDemoWeb.CodeHelpers
  import PloxDemoWeb.Headings

  def mount(_params, _session, socket) do
    data =
      [
        %{date: ~D[2023-08-01], value: 35.0, intensity: 10, temperature: :cold},
        %{date: ~D[2023-08-02], value: 60.0, intensity: 20, temperature: :cold},
        %{date: ~D[2023-08-03], value: 65.0, intensity: 25, temperature: :normal},
        %{date: ~D[2023-08-04], value: 10.0, intensity: 45, temperature: :warm},
        %{date: ~D[2023-08-05], value: 50.0, intensity: 15, temperature: :warm}
      ]

    dimensions = Plox.Dimensions.new(670, 250)

    x_axis =
      Plox.XAxis.new(Plox.DateScale.new(Date.range(~D[2023-08-01], ~D[2023-08-05])), dimensions)

    y_axis = Plox.YAxis.new(Plox.NumberScale.new(0.0, 80.0), dimensions)
    radius_axis = Plox.LinearAxis.new(Plox.NumberScale.new(10, 45), min: 4, max: 10)

    color_axis =
      Plox.ColorAxis.new(
        Plox.FixedColorsScale.new(%{cold: "#1E88E5", normal: "#43A047", warm: "#FFC107"})
      )

    dataset =
      Plox.Dataset.new(data,
        x: {x_axis, & &1.date},
        y: {y_axis, & &1.value},
        radius: {radius_axis, & &1.intensity},
        color: {color_axis, & &1.temperature}
      )
      |> dbg()

    socket =
      assign(socket,
        graph: %{
          x_axis: x_axis,
          y_axis: y_axis,
          dataset: dataset,
          dimensions: dimensions
        }
      )

    {:ok, socket}
  end

  # attr :class, :string, default: nil
  # attr :icon, :string, default: nil
  # attr :rest, :global

  # slot :inner_block, required: true

  # def my_button(assigns) do
  #   ~H"""
  #   <button class={["button", @class]} {@rest}>
  #     <.icon :if={@icon} name={@icon} class="h-4 w-4" />
  #     <%= render_slot(@inner_block) %>
  #   </button>
  #   """
  # end

  # def render(assigns) do
  #   ~H"""
  #   <p>Here is my button:</p>
  #   <.my_button
  #     class="bg-blue-500"
  #     icon="hero-bolt"
  #     phx-click={JS.push("button-clicked", value: %{count: 123})}
  #     phx-target={@myself}
  #   >
  #     Click Me!
  #   </.my_button>
  #   """
  # end

  # def handle_event("button-clicked", _, socket) do
  #   dbg("Button clicked!")
  #   {:noreply, socket}
  # end

  def render(assigns) do
    ~H"""
    <.heading1>Simple Line Plot</.heading1>

    <div class="flex flex-col 2xl:flex-row gap-4">
      <div class="space-y-4">
        <.example_graph {@graph} />

        <.heading2>HEEx Template</.heading2>

        <.code_block code={code()} />
      </div>

      <div>
        <.heading2>Setup</.heading2>

        <.code_block code={setup()} />
      </div>
    </div>
    """
  end

  defp example_graph(assigns) do
    ~H"""
    <.graph dimensions={@dimensions}>
      <%!-- <:legend>
        <.legend_item color="#EC7E16" label="Data" />
      </:legend> --%>

      <.x_axis_labels :let={date} axis={@x_axis} class="text-sm">
        <%= Calendar.strftime(date, "%-m/%-d") %>
      </.x_axis_labels>

      <.x_axis_label
        axis={@x_axis}
        value={~D[2023-08-02]}
        position={:top}
        class="text-sm fill-red-600 dark:fill-red-500"
      >
        <%= "Important Day" %>
      </.x_axis_label>

      <.x_axis_grid_lines axis={@x_axis} class="stroke-gray-100 dark:stroke-gray-900" />

      <.y_axis_labels :let={value} axis={@y_axis} ticks={5} class="text-sm">
        <%= value %>
      </.y_axis_labels>

      <.y_axis_grid_lines axis={@y_axis} ticks={5} class="stroke-gray-100 dark:stroke-gray-900" />

      <.line_plot dataset={@dataset} class="stroke-orange-500 dark:stroke-orange-400 stroke-2" />

      <.points_plot dataset={@dataset} x={:x} y={:y} fill={:color} r={:radius} />
    </.graph>
    """
  end

  defp code() do
    """
    <.graph :let={graph} id="simple_line" for={@graph} width="670" height="250">
      <:legend>
        <.legend_item color="#EC7E16" label="Data" />
      </:legend>

      <.x_axis :let={date} scale={graph[:date_scale]}>
        <%= Calendar.strftime(date, "%-m/%-d") %>
      </.x_axis>

      <.y_axis :let={value} scale={graph[:number_scale]} ticks={5}>
        <%= value %>
      </.y_axis>

      <.line_plot dataset={graph[:dataset]} />

      <.points_plot dataset={graph[:dataset]} />
    </.graph>
    """
  end

  defp setup() do
    """
    # 1. fetch data

    data = [
      %{date: ~D[2023-08-01], value: 35.0},
      %{date: ~D[2023-08-02], value: 60.0},
      %{date: ~D[2023-08-03], value: 65.0},
      %{date: ~D[2023-08-04], value: 10.0},
      %{date: ~D[2023-08-05], value: 50.0}
    ]

    # 2. set up `Plox.Scale`s for the x and y scales

    date_scale = date_scale(Date.range(~D[2023-08-01], ~D[2023-08-05]))
    number_scale = number_scale(0.0, 80.0)

    # 3. set up `Plox.Dataset`s with data and scales

    dataset =
      dataset(data,
        x: {date_scale, & &1.date},
        y: {number_scale, & &1.value}
      )

    # 4. assign newly constructed `Plox.Graph` to the socket

    assign(socket,
      graph:
        to_graph(
          scales: [date_scale: date_scale, number_scale: number_scale],
          datasets: [dataset: dataset]
        )
    )
    """
  end
end
