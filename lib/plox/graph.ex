defmodule Plox.Graph do
  defstruct datasets: %{}, scales: %{}, dimensions: nil

  def new(scales_datasets_markers) do
    scales = scales_datasets_markers |> Keyword.get(:scales, []) |> Map.new()
    datasets = scales_datasets_markers |> Keyword.get(:datasets, []) |> Map.new()

    # TODO: you could theoretically check that all scales that appear in the
    # datasets, were also given in the `scales` input

    %__MODULE__{scales: scales, datasets: datasets}
  end

  # Access behaviour

  def fetch(%__MODULE__{} = graph, key) when is_atom(key) do
    with :error <- Map.fetch(graph.datasets, key),
         :error <- Map.fetch(graph.scales, key) do
      raise ArgumentError,
            "accessing a graph with graph[key] requires the key to be the ID of a dataset or scale got: #{inspect(key)}"
    else
      {:ok, scale_or_dataset} -> {:ok, {scale_or_dataset, graph.dimensions}}
    end
  end
end
