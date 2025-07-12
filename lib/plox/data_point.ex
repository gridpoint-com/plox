defmodule Plox.DataPoint do
  @moduledoc """
  Data structure for containing raw data and its mapped values for graphing.
  """

  defstruct [:original, :graph]

  def new(original, graph) do
    %__MODULE__{original: original, graph: graph}
  end
end
