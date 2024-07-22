defmodule Plox.DateScaleTest do
  use ExUnit.Case, async: true

  alias Plox.DateScale
  alias Plox.Scale

  describe "new/2" do
    test "creates a scale from a positive range" do
      assert %DateScale{} = DateScale.new(Date.range(~D[2023-08-01], ~D[2023-08-31]))
    end

    test "creates a scale from a negative range" do
      assert %DateScale{} = DateScale.new(Date.range(~D[2023-08-31], ~D[2023-08-01], -1))
    end

    test "creates a scale from a range that technically only has 1 date (considering step)" do
      assert %DateScale{} = DateScale.new(Date.range(~D[2023-08-01], ~D[2023-08-02], 10))
    end

    test "raises if the range contains only one date" do
      assert_raise(ArgumentError, fn ->
        DateScale.new(Date.range(~D[2023-08-01], ~D[2023-08-01]))
      end)
    end

    test "raises if the range contains no dates" do
      assert_raise(ArgumentError, fn ->
        DateScale.new(Date.range(~D[2023-08-01], ~D[2023-08-02], -1))
      end)
    end
  end

  describe "implementation: Scale.values/1" do
    test "returns a Date.Range struct representing the dates to be labeled" do
      range = Date.range(~D[2023-08-01], ~D[2023-08-04], 2)

      assert ^range = range |> DateScale.new() |> Scale.values(%{step: 2})
    end

    test "works for a backwards range" do
      range = Date.range(~D[2023-08-04], ~D[2023-08-01], -2)

      assert ^range = range |> DateScale.new() |> Scale.values(%{step: 2})
    end
  end

  describe "implementation: Scale.convert_to_range/3" do
    test "returns a number" do
      scale = DateScale.new(Date.range(~D[2023-08-01], ~D[2023-08-04], 2))

      assert 20.0 = Scale.convert_to_range(scale, ~D[2023-08-02], 0..60)
    end

    test "works for a backwards range" do
      scale = DateScale.new(Date.range(~D[2023-08-04], ~D[2023-08-01], -2))

      assert 40.0 = Scale.convert_to_range(scale, ~D[2023-08-02], 0..60)
    end

    test "works even if the value is technically not in the given range (considering step)" do
      # the range's values are technically: [~D[2023-08-01], ~D[2023-08-03]]
      scale = DateScale.new(Date.range(~D[2023-08-01], ~D[2023-08-04], 2))

      assert 100.0 = Scale.convert_to_range(scale, ~D[2023-08-04], 0..100)
    end

    test "raises if given a value not valid for the scale" do
      scale = DateScale.new(Date.range(~D[2023-08-01], ~D[2023-08-04], 2))

      assert_raise(ArgumentError, fn ->
        Scale.convert_to_range(scale, ~D[2023-08-05], 0..100)
      end)
    end
  end
end
