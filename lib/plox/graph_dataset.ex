defmodule Plox.GraphDataset do
  @moduledoc """
  TODO: this is a public module that graph component implementers will interact
  with, so it should be documented
  """

  alias Plox.ColorScale
  alias Plox.DataPoint
  alias Plox.GraphScale

  defstruct [:id, :dataset, :dimensions]

  def new(id, dataset, dimensions) do
    %__MODULE__{id: id, dataset: dataset, dimensions: dimensions}
  end

  def get_point(dataset, point_id) do
    Enum.find_value(dataset.dataset.data, fn data_point ->
      if data_point.id == point_id, do: data_point
    end)
  end

  def get_scale!(%__MODULE__{dataset: dataset, dimensions: dimensions}, key) do
    case Map.fetch(dataset.scales, key) do
      {:ok, scale} ->
        GraphScale.new(key, scale, dimensions)

      :error ->
        raise ArgumentError,
          message: "No such scale #{inspect(key)} in dataset #{inspect(dataset)}"
    end
  end

  def to_graph_points(%__MODULE__{} = dataset, x_key, y_key) do
    x_scale = get_scale!(dataset, x_key)
    y_scale = get_scale!(dataset, y_key)

    Enum.map(dataset.dataset.data, fn data_point ->
      DataPoint.to_graph_point(data_point, x_scale, x_key, y_scale, y_key)
    end)
  end

  def to_graph_point(%__MODULE__{} = dataset, x_key, y_key, id) do
    x_scale = get_scale!(dataset, x_key)
    y_scale = get_scale!(dataset, y_key)

    Enum.find_value(dataset.dataset.data, fn data_point ->
      if data_point.id == id do
        DataPoint.to_graph_point(data_point, x_scale, x_key, y_scale, y_key)
      end
    end)
  end

  def to_graph_xs(%__MODULE__{} = dataset, x_key) do
    x_scale = get_scale!(dataset, x_key)

    Enum.map(dataset.dataset.data, fn data_point ->
      DataPoint.to_graph_x(data_point, x_scale, x_key)
    end)
  end

  def to_graph_ys(%__MODULE__{} = dataset, y_key) do
    y_scale = get_scale!(dataset, y_key)

    Enum.map(dataset.dataset.data, fn data_point ->
      DataPoint.to_graph_y(data_point, y_scale, y_key)
    end)
  end

  def to_color(%__MODULE__{} = _dataset, color, _data_point) when is_binary(color), do: color

  def to_color(%__MODULE__{} = dataset, key, data_point) when is_atom(key) do
    graph_scale = get_scale!(dataset, key)

    ColorScale.convert_to_color(graph_scale.scale, data_point.mapped[key])
  end
end
