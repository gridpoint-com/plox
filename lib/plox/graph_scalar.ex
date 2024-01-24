defmodule Plox.GraphScalar do
  @moduledoc """
  TODO: this is a public module that graph component implementers will interact
  with, so it should be documented
  """

  defstruct [:value, :data_point]

  def new(value, data_point) do
    %__MODULE__{value: value, data_point: data_point}
  end
end
