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
    Scale.convert_to_range(
      scale,
      value,
      (dimensions.margin.left +
         dimensions.padding.left)..(dimensions.width -
                                      dimensions.margin.right -
                                      dimensions.padding.right)
    )
  end

  def to_graph_y(%__MODULE__{scale: scale, dimensions: dimensions}, value) do
    Scale.convert_to_range(
      scale,
      value,
      (dimensions.height -
         dimensions.margin.bottom -
         dimensions.padding.bottom)..(dimensions.margin.top +
                                        dimensions.padding.top)
    )
  end
end
