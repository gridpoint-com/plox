defmodule Plox.DatasetAxis do
  @moduledoc false
  @behaviour Access

  defstruct [:dataset, :axis, :key]

  @impl Access
  def fetch(%__MODULE__{axis: axis}, value) do
    {:ok, axis[value]}
  end

  @impl Access
  def pop(_axis, _key) do
    raise "Not implemented"
  end

  # TODO: not currently being used, but maybe we can?
  @impl Access
  def get_and_update(_axis, _key, _function) do
    raise "Not implemented"
  end

  defimpl Enumerable do
    def slice(_) do
      {:error, Plox.DatasetAxis}
    end

    def member?(_, _) do
      {:error, Plox.DatasetAxis}
    end

    def count(_) do
      {:error, Plox.DatasetAxis}
    end

    def reduce(dataset_axis, acc, fun) do
      dataset_axis.dataset.data
      |> Enum.map(& &1.graph[dataset_axis.key])
      |> Enumerable.List.reduce(acc, fun)
    end
  end
end

defmodule Plox.Dataset do
  @moduledoc """
  A collection of `Plox.DataPoint`s and `Plox.Axis` implementations to convert
  the `Plox.DataPoint`s to graphable values.

  This module implements the `Access` behaviour, allowing access to axes
  using the `[]` syntax.

  ## Example

      iex> dataset = %Plox.Dataset{data: [], axes: %{x: %Plox.XAxis{}, y: %Plox.YAxis{}}}
      iex> dataset[:x]
      %Plox.DatasetAxis{axis: %Plox.XAxis{}, key: :x}

      iex> dataset = %Plox.Dataset{data: [], axes: %{x: %Plox.XAxis{}, y: %Plox.YAxis{}}}
      iex> dataset[:y]
      %Plox.DatasetAxis{axis: %Plox.YAxis{}, key: :y}

  Since `Plox.Axis` also implements the `Access` behaviour, you can access
  the graphable values more ergonomically when rendering elements in a graph:

  ## Example

      <!-- Draw red circles for every x value, but only at y = 40 on the graph -->
      <.circle cx={@dataset[:x]} cy={@dataset[:y][40]} fill="red" r="3" />
  """
  @behaviour Access

  alias Plox.DataPoint

  defstruct [:data, :axes]

  def new(original_data, axis_fns) do
    data =
      Enum.map(original_data, fn original ->
        graph = Map.new(axis_fns, fn {key, {axis, fun}} -> {key, axis[fun.(original)]} end)

        DataPoint.new(original, graph)
      end)

    axes =
      Map.new(axis_fns, fn {key, {axis, _fun}} ->
        {key, axis}
      end)

    %__MODULE__{data: data, axes: axes}
  end

  @impl Access
  def fetch(%__MODULE__{} = dataset, key) do
    with {:ok, axis} <- Map.fetch(dataset.axes, key) do
      {:ok, %Plox.DatasetAxis{dataset: dataset, axis: axis, key: key}}
    end
  end

  @impl Access
  def pop(_dataset, _key) do
    raise "Not implemented"
  end

  @impl Access
  def get_and_update(_dataset, _key, _function) do
    raise "Not implemented"
  end
end
