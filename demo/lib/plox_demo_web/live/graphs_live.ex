defmodule PloxDemoWeb.GraphsLive do
  use PloxDemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <div>
      <h1>Welcome to Plox!</h1>
      <p>Here are some demos.</p>
    </div>
    """
  end
end
