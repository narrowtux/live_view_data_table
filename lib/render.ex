defmodule LiveViewDataTable.Render do
  import Phoenix.LiveView.Helpers
  alias LiveViewDataTable.Item

  def render(assigns) do
    ~L"""
    <div class="flex flex-row">
      <div class="btn btn-success mr-2" phx-click="save">Save</div>
      <div class="btn btn-gray" phx-click="reset">Reset</div>
    </div>
    <%= if length(@contextmenu) > 0 do %>
    <div class="live-view-data-table-context-menu" style="left: <%= @x + 1 %>px; top: <%= @y + 1 %>px">
      <%= for item <- @contextmenu do %>
        <div class="item" phx-click="ctxm_click" phx-value-id="<%= item.id %>">
          <div class="icon">
            <%= if not is_nil(item.checked) do %>
              <input type="checkbox" <%= if item.checked do %>checked<% end %>>
            <% end %>
          </div>
          <%= item.display %>
        </div>
      <% end %>
    </div>
    <% end %>
    <table class="live-view-data-table" phx-hook="DataTable" id="<%= Ecto.UUID.autogenerate() %>">
      <tr class="live-view-data-table-header">
        <%= for {column, _opts} <- @columns do %>
        <th data-column="<%= column %>">
          <div class="live-view-data-table-cell">
            <%= Phoenix.Naming.humanize(column) %>
            <%= if @order_by == column do %>
              <%= if @order_direction == :asc do %>
              ▲
              <% else %>
              ▼
              <% end %>
            <% end %>
          </div>
        </th>
        <% end %>
      </tr>

      <%= for item <- @items do %>
      <tr class="<%= selection_class(@selection, item.struct.id) %>" data-id="<%= item.struct.id %>">
        <%= for {column, opts} <- @columns do %>
          <%
            value = get_value(item, column, opts)
            change = get_change(item, column, opts)
          %>
          <td data-column="<%= column %>" data-id="<%= item.struct.id %>">
            <%= if @edit_column == column && @edit_id == item.struct.id do %>
              <div class="live-view-data-table-editor-wrapper">
                <input id="cell-editor" type="text" value="<%= value %>" phx-blur="edit_blur" phx-hook="Autofocus" size="" class="live-view-data-table-editor">
              </div>
            <% end %>
            <div class="live-view-data-table-cell <%= if change != :unchanged, do: "changed", else: "" %>">
              <% renderer = Keyword.get(opts, :render_with, LiveViewDataTable.ValueRenderers.Default) %>
              <%= live_component @socket, renderer, id: "#{item.struct.id}_#{column}_cell_renderer", value: value, item: item %>
            </div>
          </td>
        <% end %>
      </tr>
      <% end %>
    </table>
    """
  end

  def selection_class(selection, id) do
    if id in selection do
      "selected"
    else
      ""
    end
  end

  def get_value(item, field, opts \\ [], default \\ nil)
  def get_value(%Item{changeset: nil, columns: columns}, field, _opts, default) do
    case Map.get(columns, field, default) do
      nil -> default
      value -> value
    end
  end
  def get_value(%Item{changeset: changeset}, field, opts, default) do
    path = path_expr(field, opts)
    AbacusSql.Update.get_field(changeset, path, default)
  end

  def get_change(%Item{changeset: nil}, _field, _opts) do
    :unchanged
  end
  def get_change(%Item{changeset: changeset}, field, opts) do
    path = path_expr(field, opts)
    AbacusSql.Update.get_change(changeset, path, :unchanged)
  end

  def path_expr(column, opts) do
    Keyword.get(opts, :path, to_string(column))
  end
end
