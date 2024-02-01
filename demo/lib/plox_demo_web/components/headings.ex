defmodule PloxDemoWeb.Headings do
  @moduledoc """
  Collection of heading components for easy reuse.
  """
  use Phoenix.Component

  slot :inner_block, required: true

  def heading1(assigns) do
    ~H"""
    <h1 class="bg-purple-100 font-bold mb-4 p-2 rounded-md text-purple-950 text-2xl w-fit">
      <%= render_slot(@inner_block) %>
    </h1>
    """
  end

  slot :inner_block, required: true

  def heading2(assigns) do
    ~H"""
    <h2 class="bg-purple-900 font-bold mb-4 p-2 rounded-md text-purple-50 w-fit">
      <%= render_slot(@inner_block) %>
    </h2>
    """
  end
end
