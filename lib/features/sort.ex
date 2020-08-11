defmodule LiveViewDataTable.Sort do
  @behaviour LiveViewDataTable.Feature
  import Phoenix.LiveView
  alias LiveViewDataTable.Private
  alias LiveViewDataTable.ContextMenuAction, as: Action

  def init(socket) do
    {:ok, socket}
  end

  def handle_data_table_event(module, {:column, :click, column, params}, socket) do
    {column, column_opts} = Private.get_column(module, column, socket)
    if Keyword.get(column_opts, :sortable, true) do
      default_order = Keyword.get(column_opts, :default_order, :asc)
      direction = case {socket.assigns.order_by, column, socket.assigns.order_direction, default_order} do
        {same, same, :asc, _} -> :desc
        {same, same, :desc, _} -> :asc
        {_old, _new, _old_order, default_order} -> default_order
      end
      socket =
        socket
        |> assign([
          order_by: column,
          order_direction: direction
        ])
        |> module.refresh()
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_data_table_event(module, {:column, :contextmenu, column, params}, socket) do
    {column, column_opts} = Private.get_column(module, column, socket)
    if Keyword.get(column_opts, :sortable, true) do
      items = [
        %Action{
          id: :sort_asc,
          display: "Sort by #{column} ascending",
          checked: socket.assigns.order_by == column && socket.assigns.order_direction == :asc,
          opts: [column: column]
        },
        %Action{
          id: :sort_desc,
          display: "Sort by #{column} descending",
          checked: socket.assigns.order_by == column && socket.assigns.order_direction == :desc,
          opts: [column: column]
        }
      ]
      socket = update(socket, :contextmenu, fn contextmenu -> contextmenu ++ items end)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_data_table_event(module, {:contextmenu_action, %{id: id} = item}, socket) when id in [:sort_asc, :sort_desc] do
    direction = case item.id do
      :sort_asc -> :asc
      :sort_desc -> :desc
    end
    socket =
      socket
      |> assign([
        order_by: Keyword.get(item.opts, :column, :id),
        order_direction: direction
      ])
      |> module.refresh()

    {:noreply, socket}
  end

  def handle_data_table_event(_, _, socket) do
    {:noreply, socket}
  end
end
