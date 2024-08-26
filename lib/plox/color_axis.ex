defmodule Plox.ColorAxis do
  @moduledoc """
  TODO: this is a public module that graph component implementers will interact
  with, so it should be documented
  """

  alias Plox.ColorScale

  defstruct [:scale]

  def new(scale) do
    %__MODULE__{scale: scale}
  end

  # def values(%__MODULE__{scale: scale}, opts \\ %{}), do: Scale.values(scale, opts)

  defimpl Plox.Axis do
    def to_graph(%{scale: scale}, value) do
      ColorScale.convert_to_color(scale, value)
    end
  end
end
