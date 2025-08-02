defmodule Plox.GraphScale do
  @moduledoc """
  TODO: this is a public module that graph component implementers will interact
  with, so it should be documented
  """

  alias Plox.Scale

  defstruct [:id, :scale, :dimensions]

  def new(id, scale, dimensions) do
    %__MODULE__{id: id, scale: scale, dimensions: dimensions}
  end

  def values(%__MODULE__{scale: scale}, opts \\ %{}), do: Scale.values(scale, opts)

  def to_graph_x(%__MODULE__{scale: scale, dimensions: dimensions}, value) do
    first = dimensions.margin.left + dimensions.padding.left
    last = dimensions.width - dimensions.margin.right - dimensions.padding.right
    step = if first < last, do: 1, else: -1

    Scale.convert_to_range(scale, value, first..last//step)
  end

  def to_graph_y(%__MODULE__{scale: scale, dimensions: dimensions}, value) do
    first = dimensions.height - dimensions.margin.bottom - dimensions.padding.bottom
    last = dimensions.margin.top + dimensions.padding.top
    step = if first < last, do: 1, else: -1

    Scale.convert_to_range(scale, value, first..last//step)
  end
end
