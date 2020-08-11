defmodule LiveViewDataTable do
  alias __MODULE__.Item
  @type socket :: Phoenix.LiveView.Socket.t()
  @type item :: Item.t()
  @type column :: atom()
  @type column_opts :: keyword()
  @type event_params :: %{}
  @type event_type ::
    :click | :dblclick | :contextmenu | :mousedown |
    :mouseup | :mousemove | :selected | :unselected
  @type event ::
    {:column, event_type(), column(), event_params()} |
    {:cell, event_type(), item(), column(), event_params()} |
    {:item, event_type(), item(), event_params()}

  @callback handle_data_table_event(event, socket()) :: {:noreply, socket()}
  @callback handle_live_view_event(event(), event_params(), socket()) :: {:noreply, socket()}
  @callback data_source(socket) :: {module(), __MODULE__.DataSource.opts()}
  @callback get_column(binary() | atom()) :: {atom(), column_opts()} | nil

  defmacro __using__(opts \\ []) do
    features = Keyword.get(opts, :features, [
      LiveViewDataTable.Sort,
      LiveViewDataTable.CopyValue
    ])
    quote do
      use Phoenix.LiveView
      alias unquote(__MODULE__).Private

      @behaviour unquote(__MODULE__)

      def handle_event(_, socket) do
        {:noreply, socket}
      end

      def handle_cell_event(_, socket) do
        {:noreply, socket}
      end

      def mount(params, session, socket) do
        Private.mount(__MODULE__, unquote(features), params, session, socket)
      end

      def refresh(socket) do
        Private.refresh(__MODULE__, unquote(features), socket)
      end

      def handle_event(event, params, socket) do
        Private.handle_event(__MODULE__, unquote(features), event, params, socket)
      end

      def handle_live_view_event(_event, _params, socket) do
        {:noreply, socket}
      end

      def handle_data_table_event(_event, socket) do
        {:noreply, socket}
      end

      def get_column(column, socket) do
        Private.get_column(__MODULE__, column, socket)
      end

      def get_columns(socket) do
        Private.get_columns(__MODULE__, socket)
      end

      defdelegate render(assigns), to: unquote(__MODULE__).Render

      defoverridable(Phoenix.LiveView)
      defoverridable(unquote(__MODULE__))
    end
  end
end
