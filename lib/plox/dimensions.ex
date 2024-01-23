defmodule Plox.Dimensions do
  @moduledoc """
  TODO: this is a public module that graph component implementers will interact
  with, so it should be documented
  """

  alias Plox.Box

  defstruct [:width, :height, :margin, :padding]

  def new(attrs) do
    %__MODULE__{
      width: number(attrs.width),
      height: number(attrs.height),
      margin: Box.new(attrs.margin),
      padding: Box.new(attrs.padding)
    }
  end

  defp number(string) when is_binary(string), do: String.to_integer(string)
  defp number(number) when is_number(number), do: number
end
