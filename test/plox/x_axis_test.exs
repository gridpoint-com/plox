defmodule Plox.XAxisTest do
  use ExUnit.Case

  alias Plox.Axis
  alias Plox.XAxis

  doctest XAxis

  setup do
    %{
      scale: Plox.NumberScale.new(0, 10),
      dimensions: Plox.Dimensions.new(100, 100, margin: 0)
    }
  end

  test "new/2", %{scale: scale, dimensions: dimensions} do
    assert XAxis.new(scale, dimensions) == %XAxis{
             scale: scale,
             dimensions: dimensions
           }
  end

  test "implements to_graph/2", %{scale: scale, dimensions: dimensions} do
    x_axis = XAxis.new(scale, dimensions)

    assert Axis.Protocol.to_graph(x_axis, 1) == 10.0
    assert Axis.Protocol.to_graph(x_axis, 2) == 20.0
  end

  test "fetches graphable values using Access syntax", %{scale: scale, dimensions: dimensions} do
    x_axis = XAxis.new(scale, dimensions)

    assert x_axis[1] == 10.0
    assert x_axis[2] == 20.0
  end
end
