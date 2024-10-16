defmodule Plox.FixedValuesScaleTest do
  use ExUnit.Case, async: true

  alias Plox.FixedValuesScale
  alias Plox.Scale

  describe "new/2" do
    test "creates a scale from any enumerable" do
      assert %FixedValuesScale{} = FixedValuesScale.new([:foo, :bar, :baz])
      assert %FixedValuesScale{} = FixedValuesScale.new(1..10)

      # it's silly, but just to prove the point
      assert %FixedValuesScale{} =
               FixedValuesScale.new(0 |> Stream.unfold(&{&1, &1 + 1}) |> Stream.take(10))
    end

    test "raises if given no values" do
      assert_raise(ArgumentError, fn ->
        FixedValuesScale.new([])
      end)
    end

    test "raises if given only one value" do
      assert_raise(ArgumentError, fn ->
        FixedValuesScale.new([:foo])
      end)
    end
  end

  describe "implementation: Scale.values/1" do
    test "returns an ordered list of all the values given" do
      assert [:foo, :bar, :baz] = [:foo, :bar, :baz] |> FixedValuesScale.new() |> Scale.values(%{})
      assert [1, 2, 3, 4, 5] = 1..5 |> FixedValuesScale.new() |> Scale.values(%{})
    end
  end

  describe "implementation: Scale.convert_to_range/3" do
    test "returns a number" do
      scale = FixedValuesScale.new([:foo, :bar, :baz])

      assert 50.0 = Scale.convert_to_range(scale, :bar, 0..100)
    end

    test "raises if given a value not valid for the scale" do
      scale = FixedValuesScale.new([:foo, :bar, :baz])

      assert_raise(ArgumentError, fn ->
        Scale.convert_to_range(scale, :lol, 0..100)
      end)
    end
  end
end
