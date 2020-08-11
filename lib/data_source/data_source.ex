defmodule LiveViewDataTable.DataSource do
  @type opts :: [option]
  @type option ::
    {:order_by, LiveViewDataTable.column()} |
    {:order_direction, :asc | :desc} |
    {:limit, non_neg_integer()} |
    {:offset, non_neg_integer()} |
    {:columns, [{LiveViewDataTable.column(), LiveViewDataTable.column_opts()}]} |
    {:schema, module()} |
    {atom(), any()}
  @type item :: LiveViewDataTable.Item.t()
  @type changeset :: Ecto.Changeset.t()

  @callback all(opts()) :: [item]
  @callback transaction(fun :: (-> any()), opts()) :: {:ok, any()} | {:error, term()}
  @callback insert(changeset(), opts()) :: {:ok, item()} | {:error, changeset()}
  @callback update(changeset(), opts()) :: {:ok, item()} | {:error, changeset()}
  @callback delete_all([item()], opts()) :: :ok | {:error, item(), changeset()}
end
