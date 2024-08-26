defmodule Plox.XAxis do
  @moduledoc """
  TODO: this is a public module that graph component implementers will interact
  with, so it should be documented
  """

  alias Plox.Scale

  defstruct [:scale, :dimensions]

  def new(scale, dimensions) do
    %__MODULE__{scale: scale, dimensions: dimensions}
  end

  def values(%__MODULE__{scale: scale}, opts \\ %{}), do: Scale.values(scale, opts)

  defimpl Plox.Axis do
    def to_graph(%{scale: scale, dimensions: dimensions}, value) do
      Scale.convert_to_range(
        scale,
        value,
        (dimensions.margin.left +
           dimensions.padding.left)..(dimensions.width -
                                        dimensions.margin.right -
                                        dimensions.padding.right)
      )
    end
  end
end
