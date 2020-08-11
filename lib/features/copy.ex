defmodule LiveViewDataTable.CopyValue do
  @behaviour LiveViewDataTable.Feature
  alias LiveViewDataTable.ContextMenuAction, as: Action
  import Phoenix.LiveView

  def init(socket) do
    {:ok, socket}
  end

  def handle_data_table_event(module, {:cell, :contextmenu, column, item, params}, socket) do
    actions = [
      %Action{
        id: :copy_cell,
        display: "Copy #{column} value",
        opts: [item: item, column: column]
      },
      %Action{
        id: :copy_item_table,
        display: "Copy row",
        opts: [item: item]
      },
      %Action{
        id: :copy_item_json,
        display: "Copy row as JSON",
        opts: [item: item]
      }
    ]

    {:noreply, assign(socket, contextmenu: actions)}
  end

  def handle_data_table_event(module, {:contextmenu_action, %{id: id} = action}, socket) when id in ~w[copy_cell copy_item_table copy_item_json]a do
    item = Keyword.get(action.opts, :item)
    column = Keyword.get(action.opts, :column)
    {value, format} = case id do
      :copy_cell ->
        {Map.get(item.struct, column), "text"}

      :copy_item_table ->
        columns = module.get_columns(socket)
        values = Enum.map(columns, fn {column, _} ->
          to_string(Map.get(item.columns, column))
        end)
        {[values], "table"}

      :copy_item_json ->
        {Jason.encode!(item.columns), "json"}
    end

    socket = push_event(socket, "lvdt_copy", %{value: value, format: format})

    {:noreply, socket}
  end

  def handle_data_table_event(_module, _event, socket) do
    {:noreply, socket}
  end
end
