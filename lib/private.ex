defmodule LiveViewDataTable.Private do
  import Phoenix.LiveView
  alias LiveViewDataTable.Item

  def data_source_opts(module, socket) do
    {data_source, user_opts} = module.data_source(socket)

    defaults = [
      order_by: :id,
      order_direction: :asc,
      limit: 50,
      offset: 0
    ]

    from_socket = Map.take(socket.assigns, Keyword.keys(defaults)) |> Enum.into([])

    opts =
      defaults
      |> Keyword.merge(from_socket)
      |> Keyword.merge(user_opts)

    {data_source, opts}
  end

  def mount(module, features, params, session, socket) do
    socket = assign(socket, [
        order_by: :id,
        order_direction: :asc,
        limit: 50,
        offset: 0,
        selection: [],
        edit_column: nil,
        contextmenu: []
      ])
    socket = refresh(module, features, socket)
    socket = Enum.reduce(features, socket, fn feature, socket ->
      {:ok, socket} = feature.init(socket)
      socket
    end)
    {:ok, socket}
  end

  def refresh(module, _features, socket) do
    {data_source, data_opts} = data_source_opts(module, socket)

    items = data_source.all(data_opts)

    assign(socket, items: items, columns: module.get_columns(socket))
  end

  def handle_event(module, features, "ctxm_click", %{"id" => param_id} = params, socket) do
    menu_action = Enum.find(socket.assigns.contextmenu, fn %{id: id} ->
      to_string(id) == to_string(param_id)
    end)

    socket = assign(socket, :contextmenu, [])

    if menu_action do
      call_data_table_event(module, features, {:contextmenu_action, menu_action}, socket)
    else
      {:noreply, socket}
    end
  end

  def handle_event(module, features, event, params, socket) do
    events = ~w[click dblclick contextmenu mousedown mouseup mousemove]a
    converted_event = Enum.find(events, &(to_string(&1) == event))
    item = get_item(module, Map.get(params, "id"), socket)
    column = get_column(module, Map.get(params, "column"), socket)

    socket = if converted_event in [:contextmenu, :mousedown] do
      assign(socket, [
        contextmenu: [],
        x: Map.get(params, "x"), y: Map.get(params, "y")
      ])
    else
      socket
    end

    case {converted_event, item, column} do
      {event, nil, nil} when not is_nil(event) -> call_data_table_event(module, features, {:table, event, params}, socket)
      {event, nil, {column, _opts}} when not is_nil(event) -> call_data_table_event(module, features, {:column, event, column, params}, socket)
      {event, %Item{} = item, nil} when not is_nil(event) -> call_data_table_event(module, features, {:item, event, item, params}, socket)
      {event, %Item{} = item, {column, _opts}} when not is_nil(event) -> call_data_table_event(module, features, {:cell, event, column, item, params}, socket)
      _ ->  module.handle_live_view_event(event, params, socket)
    end
  end

  def call_data_table_event(module, features, event, socket) do
    socket = Enum.reduce(features, socket, fn mod, socket ->
      {:noreply, socket} = mod.handle_data_table_event(module, event, socket)
      socket
    end)
    module.handle_data_table_event(event, socket)
  end

  def get_column(module, column, socket) do
    Enum.find(module.get_columns(socket), fn {c, _} ->
      to_string(c) == to_string(column)
    end)
  end

  def get_columns(module, socket) do
    {_, opts} = module.data_source(socket)
    Keyword.get(opts, :columns, [])
  end

  def get_item(_module, id, socket) do
    Enum.find(socket.assigns.items, fn item ->
      to_string(item.struct.id) == to_string(id)
    end)
  end
end
