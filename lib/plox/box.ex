defmodule Plox.Box do
  @moduledoc """
  TODO: this is a public module that graph component implementers will interact
  with, so it should be documented
  """

  defstruct [:top, :right, :bottom, :left]

  def new(string) when is_binary(string) do
    string
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
    |> new()
  end

  def new({n}) when is_number(n), do: new(n)

  def new(n) when is_number(n), do: %__MODULE__{top: n, right: n, bottom: n, left: n}

  def new({top_bottom, right_left}),
    do: %__MODULE__{top: top_bottom, right: right_left, bottom: top_bottom, left: right_left}

  def new({top, right_left, bottom}), do: %__MODULE__{top: top, right: right_left, bottom: bottom, left: right_left}

  def new({top, right, bottom, left}), do: %__MODULE__{top: top, right: right, bottom: bottom, left: left}
end
