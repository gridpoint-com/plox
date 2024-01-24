defmodule Plox.GraphDataset do
  @moduledoc """
  TODO: this is a public module that graph component implementers will interact
  with, so it should be documented
  """

  alias Plox.GraphScale

  defstruct [:id, :dataset, :dimensions]

  def new(id, dataset, dimensions) do
    %__MODULE__{id: id, dataset: dataset, dimensions: dimensions}
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

    for %{^x_key => x_value, ^y_key => y_value} = datum <- dataset.dataset.data do
      {GraphScale.to_graph_x(x_scale, x_value), GraphScale.to_graph_y(y_scale, y_value), datum}
    end
  end

  def to_graph_point(%__MODULE__{} = dataset, x_key, y_key, id) do
    x_scale = get_scale!(dataset, x_key)
    y_scale = get_scale!(dataset, y_key)

    Enum.find_value(dataset.dataset.data, fn datum ->
      if datum.id == id do
        %{^x_key => x_value, ^y_key => y_value} = datum

        {GraphScale.to_graph_x(x_scale, x_value), GraphScale.to_graph_y(y_scale, y_value), datum}
      end
    end)
  end
end
