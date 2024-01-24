defmodule Plox.Dataset do
  @moduledoc """
  A collection of data points and some metadata for a graph
  """
  alias Plox.DataPoint

  defstruct [:data, :scales]

  def new(original_data, axes) do
    scales = Map.new(axes, fn {key, {scale, _fun}} -> {key, scale} end)

    data =
      original_data
      |> Enum.with_index()
      |> Enum.map(fn {original, idx} ->
        id = Map.get(original, :id, idx)

        mapped =
          Map.new(axes, fn {key, {_scale, fun}} ->
            {key, fun.(original)}
          end)

        DataPoint.new(id, original, mapped)
      end)

    %__MODULE__{data: data, scales: scales}
  end
end
