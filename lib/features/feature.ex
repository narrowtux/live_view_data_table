defmodule LiveViewDataTable.Feature do
  @callback init(Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  @callback handle_data_table_event(module(), LiveViewDataTable.event(), Phoenix.LiveView.Socket.t()) :: {:noreply, Phoenix.LiveView.Socket.t()}
end
