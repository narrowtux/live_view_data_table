defmodule LiveViewDataTable.ValueRenderers.Default do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <span><%= to_string(@value) %></span>
    """
  end
end
