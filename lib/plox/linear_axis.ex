defmodule Plox.LinearAxis do
  @moduledoc """
  TODO: this is a public module that graph component implementers will interact
  with, so it should be documented
  """

  alias Plox.Scale

  defstruct [:scale, :min, :max]

  def new(scale, opts \\ []) do
    Keyword.validate!(opts, [:min, :max])
    min = Keyword.fetch!(opts, :min)
    max = Keyword.fetch!(opts, :max)

    %__MODULE__{scale: scale, min: min, max: max}
  end

  def values(%__MODULE__{scale: scale}, opts \\ %{}), do: Scale.values(scale, opts)

  defimpl Plox.Axis do
    def to_graph(%{scale: scale, min: min, max: max}, value) do
      Scale.convert_to_range(scale, value, min..max)
    end
  end
end
