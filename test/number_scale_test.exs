defmodule Plox.NumberScaleTest do
  use ExUnit.Case, async: true

  alias Plox.NumberScale
  alias Plox.Scale

  describe "new/2" do
    test "creates a scale from floats" do
      assert %NumberScale{} = NumberScale.new(0.0, 100.0)
    end

    test "creates a scale from integers" do
      assert %NumberScale{} = NumberScale.new(0, 100)
    end

    test "creates a backwards scale" do
      assert %NumberScale{} = NumberScale.new(100, 0)
    end

    test "raises if min and max are equal" do
      assert_raise(ArgumentError, fn ->
        NumberScale.new(0, 0)
      end)
    end
  end

  describe "implementation: Scale.values/1" do
    test "works if given floats" do
      scale = NumberScale.new(0.0, 100.0)

      assert [+0.0, 10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0] =
               Scale.values(scale, %{})
    end

    test "works if given integers" do
      scale = NumberScale.new(0, 1)

      assert [+0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0] = Scale.values(scale, %{})
    end

    test "doesn't have floating point rounding errors" do
      scale = NumberScale.new(0.0, 1.0)

      # with the older floats implementation this would result in:
      # [0.0, 0.2, 0.4, 0.6000000000000001, 0.8, 1.0]
      assert [+0.0, 0.2, 0.4, 0.6, 0.8, 1.0] = Scale.values(scale, %{ticks: 6})
    end

    test "works for backwards scales" do
      scale = NumberScale.new(10, 0)

      assert [10.0, 8.0, 6.0, 4.0, 2.0, +0.0] = Scale.values(scale, %{ticks: 6})
    end

    test "works for negative numbers" do
      scale = NumberScale.new(-1.5, 1.5)

      assert [-1.5, -1.0, -0.5, +0.0, 0.5, 1.0, 1.5] = Scale.values(scale, %{ticks: 7})
    end
  end

  describe "implementation: Scale.convert_to_range/3" do
    test "works if given integers" do
      scale = NumberScale.new(0, 4)

      assert 25.0 = Scale.convert_to_range(scale, 1, 0..100)
    end

    test "works if given floats" do
      scale = NumberScale.new(0.0, 10.0)

      assert 40.0 = Scale.convert_to_range(scale, 4.0, 0..100)
    end

    test "works for backwards scales" do
      scale = NumberScale.new(10, 0)

      assert 60.0 = Scale.convert_to_range(scale, 4, 0..100)
    end

    test "works for negative numbers" do
      scale = NumberScale.new(-1.5, 1.5)

      assert 10.0 = Scale.convert_to_range(scale, -1.2, 0..100)
    end

    # There used to be a raise when the value was out of range, but that is no longer in place
    # test "raises if given a value outside of the scale" do
    #   scale = NumberScale.new(0, 10)

    #   assert_raise(ArgumentError, fn ->
    #     Scale.convert_to_range(scale, 15, 0..100)
    #   end)
    # end
  end
end
