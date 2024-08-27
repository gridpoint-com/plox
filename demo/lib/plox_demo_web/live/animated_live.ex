defmodule PloxDemoWeb.AnimatedLive do
  use PloxDemoWeb, :live_view

  import Plox

  @interval 1000

  @impl true
  def render(assigns) do
    ~H"""
    <.graph dimensions={@dimensions}>
      <.y_axis_labels :let={value} axis={@y_axis} ticks={5} class="text-sm">
        <%= value %>
      </.y_axis_labels>

      <.y_axis_grid_lines axis={@y_axis} ticks={5} class="stroke-gray-900" />

      <.x_axis_labels
        :let={datetime}
        axis={@x_axis}
        step={5}
        start={@nearest_5_second}
        class="text-sm"
      >
        <%= Calendar.strftime(datetime, "%-I:%M:%S") %>
      </.x_axis_labels>

      <.x_axis_grid_lines axis={@x_axis} step={5} start={@nearest_5_second} class="stroke-gray-900" />
      <.x_axis_grid_line axis={@x_axis} value={@x_axis.scale.first} class="stroke-gray-900" />
      <.x_axis_grid_line axis={@x_axis} value={@x_axis.scale.last} class="stroke-gray-900" />

      <.x_axis_label axis={@x_axis} value={@now} class="text-sm" position={:top} class="fill-red-600">
        Now (<%= Calendar.strftime(@now, "%-I:%M:%S") %>)
      </.x_axis_label>

      <.x_axis_grid_line axis={@x_axis} value={@now} class="stroke-red-600" />

      <.line_plot dataset={@dataset1} class="stroke-orange-500" stroke-width="2" />
      <.line_plot dataset={@dataset2} class="stroke-blue-500" stroke-width="2" />
      <.line_plot dataset={@dataset3} class="stroke-green-500" stroke-width="2" />

      <.points_plot dataset={@points_dataset} r={:r} fill={:color} />
    </.graph>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    dimensions = Plox.Dimensions.new(1_000, 250)

    if connected?(socket) do
      Process.send_after(self(), :tick, @interval)
      Process.send_after(self(), :add_point, :rand.uniform(10) * 1_000)
    end

    now = DateTime.utc_now() |> DateTime.truncate(:second)
    soon = DateTime.add(now, 5, :second)
    start = DateTime.add(soon, -60, :second)
    nearest_5_second = get_nearest_5_second(start)

    x_axis =
      Plox.XAxis.new(
        Plox.DateTimeScale.new(
          start,
          soon
        ),
        dimensions
      )

    y_axis = Plox.YAxis.new(Plox.NumberScale.new(0, 100), dimensions)

    radius_axis = Plox.LinearAxis.new(Plox.NumberScale.new(1, 100), min: 5, max: 15)

    color_axis =
      Plox.ColorAxis.new(
        Plox.FixedColorsScale.new(%{cold: "#1E88E5AA", normal: "#43A047AA", warm: "#FFC107AA"})
      )

    {data1, dataset1} = init_line_data(now, x_axis, y_axis)
    {data2, dataset2} = init_line_data(now, x_axis, y_axis)
    {data3, dataset3} = init_line_data(now, x_axis, y_axis)

    points = []

    points_dataset =
      Plox.Dataset.new(points,
        x: {x_axis, & &1.x},
        y: {y_axis, & &1.y},
        r: {radius_axis, & &1.size},
        color: {color_axis, & &1.temperature}
      )

    {:ok,
     assign(socket,
       now: now,
       data1: data1,
       dataset1: dataset1,
       data2: data2,
       dataset2: dataset2,
       data3: data3,
       dataset3: dataset3,
       points: points,
       points_dataset: points_dataset,
       x_axis: x_axis,
       y_axis: y_axis,
       radius_axis: radius_axis,
       color_axis: color_axis,
       dimensions: dimensions,
       nearest_5_second: nearest_5_second
     )}
  end

  @impl true
  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, @interval)

    now = DateTime.utc_now() |> DateTime.truncate(:second)
    soon = DateTime.add(now, 5, :second)
    start = DateTime.add(soon, -60, :second)
    nearest_5_second = get_nearest_5_second(start)

    x_axis =
      Plox.XAxis.new(
        Plox.DateTimeScale.new(
          start,
          soon
        ),
        socket.assigns.dimensions
      )

    {data1, dataset1} = update_line_data(socket.assigns.data1, now, x_axis, socket.assigns.y_axis)
    {data2, dataset2} = update_line_data(socket.assigns.data2, now, x_axis, socket.assigns.y_axis)
    {data3, dataset3} = update_line_data(socket.assigns.data3, now, x_axis, socket.assigns.y_axis)

    points =
      Enum.take_while(socket.assigns.points, fn %{x: time} ->
        DateTime.compare(time, x_axis.scale.first) != :lt
      end)

    points_dataset =
      Plox.Dataset.new(points,
        x: {socket.assigns.x_axis, & &1.x},
        y: {socket.assigns.y_axis, & &1.y},
        r: {socket.assigns.radius_axis, & &1.size},
        color: {socket.assigns.color_axis, & &1.temperature}
      )

    {:noreply,
     assign(socket,
       now: now,
       data1: data1,
       dataset1: dataset1,
       data2: data2,
       dataset2: dataset2,
       data3: data3,
       dataset3: dataset3,
       points: points,
       points_dataset: points_dataset,
       x_axis: x_axis,
       nearest_5_second: nearest_5_second
     )}
  end

  def handle_info(:add_point, socket) do
    Process.send_after(self(), :add_point, :rand.uniform(10) * 1_000)

    new_point = %{
      x: socket.assigns.now,
      y: :rand.uniform(100),
      size: :rand.uniform(100),
      temperature: Enum.random(~w(cold normal warm)a)
    }

    points = [new_point | socket.assigns.points]

    {:noreply, assign(socket, points: points)}
  end

  defp get_nearest_5_second(datetime) do
    seconds = datetime.second

    diff = ceil(seconds / 5) * 5 - seconds

    DateTime.add(datetime, diff)
  end

  defp init_line_data(now, x_axis, y_axis) do
    data = [%{x: now, y: :rand.uniform(100)}]

    dataset = Plox.Dataset.new(data, x: {x_axis, & &1.x}, y: {y_axis, & &1.y})

    {data, dataset}
  end

  defp update_line_data(data, now, x_axis, y_axis) do
    [previous | _] = data

    diff =
      case previous.y do
        100 -> :rand.uniform(10) - 10
        0 -> :rand.uniform(10)
        _ -> :rand.uniform(20) - 10
      end

    new = min(max(previous.y + diff, 0), 100)

    data =
      Enum.take_while([%{x: now, y: new} | data], fn %{x: time} ->
        DateTime.compare(time, x_axis.scale.first) != :lt
      end)

    dataset =
      Plox.Dataset.new(data,
        x: {x_axis, & &1.x},
        y: {y_axis, & &1.y}
      )

    {data, dataset}
  end
end
