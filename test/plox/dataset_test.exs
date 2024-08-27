defmodule Plox.DatasetTest do
  use ExUnit.Case

  alias Plox.DataPoint
  alias Plox.Dataset

  doctest Dataset

  test "new/2" do
    scale = Plox.number_scale(0, 10)
    axes = %{x: {scale, & &1.foo}, y: {scale, & &1.bar}}
    data = [%{foo: 1, bar: 2}, %{foo: 2, bar: 3}]
    dataset = Dataset.new(data, axes)

    assert dataset.scales == %{x: scale, y: scale}

    assert dataset.data == [
             %DataPoint{id: 0, original: %{foo: 1, bar: 2}, mapped: %{x: 1, y: 2}},
             %DataPoint{id: 1, original: %{foo: 2, bar: 3}, mapped: %{x: 2, y: 3}}
           ]
  end
end
