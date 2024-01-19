defmodule Plox.Dataset do
  @moduledoc """
  A collection of data points and some metadata for a graph
  """
  defstruct [:data, :scales]

  def new(data, axes) do
    scales = Map.new(axes, fn {key, {scale, _fun}} -> {key, scale} end)

    data =
      data
      |> Enum.with_index()
      |> Enum.map(fn {datum, idx} ->
        Map.merge(
          datum,
          Map.new(axes, fn {key, {_scale, fun}} ->
            {key, fun.(datum)}
          end)
        )
        |> Map.put_new(:id, idx)
      end)

    %__MODULE__{data: data, scales: scales}
  end
end
