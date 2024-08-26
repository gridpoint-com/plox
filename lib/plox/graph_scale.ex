defmodule Plox.GraphScale do
  @moduledoc """
  TODO: this is a public module that graph component implementers will interact
  with, so it should be documented
  """

  alias Plox.Scale

  defstruct [:scale, :graph]

  def new(graph, scale) do
    %__MODULE__{scale: scale, graph: graph}
  end

  def values(%__MODULE__{scale: scale}, opts \\ %{}), do: Scale.values(scale, opts)

  def to_graph_x(%__MODULE__{scale: scale, graph: graph}, value) do
    Scale.convert_to_range(
      scale,
      value,
      (graph.margin.left +
         graph.padding.left)..(graph.width -
                                 graph.margin.right -
                                 graph.padding.right)
    )
  end

  def to_graph_y(%__MODULE__{scale: scale, graph: graph}, value) do
    Scale.convert_to_range(
      scale,
      value,
      (graph.height -
         graph.margin.bottom -
         graph.padding.bottom)..(graph.margin.top +
                                   graph.padding.top)
    )
  end
end
