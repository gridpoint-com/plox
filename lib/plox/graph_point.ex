defmodule Plox.GraphPoint do
  @moduledoc """
  TODO: this is a public module that graph component implementers will interact
  with, so it should be documented
  """

  defstruct [:x, :y, :data_point]

  def new(x, y, data_point) do
    %__MODULE__{x: x, y: y, data_point: data_point}
  end
end
