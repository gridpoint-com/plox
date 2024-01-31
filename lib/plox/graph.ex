defmodule Plox.Graph do
  @moduledoc """
  TODO: docs
  """

  alias Plox.Dataset
  alias Plox.Dimensions
  alias Plox.GraphDataset
  alias Plox.GraphScale

  defstruct datasets: %{}, scales: %{}, color_scales: %{}, dimensions: nil

  def new(scales_and_datasets) do
    scales = scales_and_datasets |> Keyword.get(:scales, []) |> Map.new()
    color_scales = scales_and_datasets |> Keyword.get(:color_scales, []) |> Map.new()
    datasets = scales_and_datasets |> Keyword.get(:datasets, []) |> Map.new()

    # TODO: you could theoretically check that all scales that appear in the
    # datasets, were also given in the `scales` input

    %__MODULE__{scales: scales, color_scales: color_scales, datasets: datasets}
  end

  def put_dimensions(%__MODULE__{} = graph, %Dimensions{} = dimensions) do
    %{graph | dimensions: dimensions}
  end

  # Access behaviour

  def fetch(%__MODULE__{} = graph, key) do
    with :error <- Map.fetch(graph.datasets, key),
         :error <- Map.fetch(graph.scales, key) do
      raise ArgumentError,
            "accessing a graph with graph[key] requires the key to be the ID of a dataset or scale got: #{inspect(key)}"
    else
      {:ok, %Dataset{} = dataset} -> {:ok, GraphDataset.new(key, dataset, graph.dimensions)}
      {:ok, scale} -> {:ok, GraphScale.new(key, scale, graph.dimensions)}
    end
  end
end
