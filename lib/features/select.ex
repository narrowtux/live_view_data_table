defmodule LiveViewDataTable.Select do
  @behaviour LiveViewDataTable.Feature
  import Phoenix.LiveView
  alias LiveViewDataTable.Private
  alias LiveViewDataTable.ContextMenuAction, as: Action

  defstruct [start: nil, end: nil, remove: false]

  alias __MODULE__, as: Sel

  def init(socket) do
    {:ok, assign(socket, selections: [], selecting?: false)}
  end

  def handle_data_table_event(module, {:cell, :mousedown, _column, item, %{"button" => 0} = params}, socket) do
    index = Enum.find_index(socket.assigns.items, &(&1.id == item.id))
    shift = Map.get(params, "shift_key", false)
    ctrl = Map.get(params, "ctrl_key", false) or Map.get(params, "meta_key", false)
    remove = item.id in socket.assigns.selection

    selections = case {shift, ctrl, socket.assigns.selections} do
      {_, _, []} -> [%Sel{start: index, end: index}]
      {false, false, _} -> [%Sel{start: index, end: index}]
      {true, false, [first | rest]} -> [%{ first | end: index } | rest ]
      {_, true, rest} -> [%Sel{start: index, end: index, remove: remove} | rest]
    end

    socket =
      socket
      |> assign([
        selecting?: true,
        selections: selections
      ])
      |> update_selection()

    {:noreply, socket}
  end

  def handle_data_table_event(module, {:cell, :mousemove, _column, item, _}, %{assigns: %{selecting?: true}} = socket) do
    index = Enum.find_index(socket.assigns.items, &(&1.id == item.id))

    [current | rest] = socket.assigns.selections
    selections = [%{ current | end: index } | rest]

    socket =
      socket
      |> assign(selections: selections)
      |> update_selection()

    {:noreply, socket}
  end

  def handle_data_table_event(module, {:cell, :mouseup, _column, item, %{"button" => 0}}, %{assigns: %{selecting?: true}} = socket) do
    index = Enum.find_index(socket.assigns.items, &(&1.id == item.id))

    [current | rest] = socket.assigns.selections
    selections = [%{ current | end: index } | rest]

    socket =
      socket
      |> assign([
        selections: selections,
        selecting?: false
      ])
      |> update_selection()

    {:noreply, socket}
  end

  def handle_data_table_event(module, {:table, :mouseup, %{"button" => 0}}, %{assigns: %{selecting?: true}} = socket) do
    {:noreply, assign(socket, :selecting?, false)}
  end

  def handle_data_table_event(_module, _event, socket) do
    {:noreply, socket}
  end

  def update_selection(socket) do
    selection =
      socket.assigns.selections
      |> Enum.reverse()
      |> Enum.reduce([], fn sel, acc ->
        range =
          min(sel.start, sel.end)..max(sel.start, sel.end)
          |> Enum.into([])
        case sel.remove do
          true -> Enum.uniq(acc -- range)
          false -> Enum.uniq(acc ++ range)
        end
      end)
      |> Enum.map(fn index ->
        case Enum.at(socket.assigns.items, index) do
          %{id: id} -> id
          _ -> nil
        end
      end)

    assign(socket, :selection, selection)
  end
end
