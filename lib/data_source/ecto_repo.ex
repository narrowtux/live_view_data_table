defmodule LiveViewDataTable.DataSources.EctoRepo do
  import Ecto.Query

  @behaviour LiveViewDataTable.DataSource

  @type opts :: [option()]
  @type option ::
    LiveViewDataTable.DataSource.option() |
    {:filter, binary()} |
    {:repo, module()} |
    {:base_query, {module(), atom()}}

  def all(opts) do
    my_columns = Keyword.get(opts, :columns, [])

    query =
      base_query(opts)
      |> AbacusSql.where(Keyword.get(opts, :filter, "true"))

    query = Enum.reduce(my_columns, query, fn {column, opts}, query ->
      AbacusSql.select(query, column, path_expr(column, opts))
    end)
    query = AbacusSql.select(query, :id, "id")
    order_by = Keyword.get(opts, :order_by, :id)
    order_by = path_expr(order_by, Keyword.get(my_columns, order_by, []))
    query = AbacusSql.order_by(query, order_by, Keyword.get(opts, :order_direction, :asc) == :asc)

    query = from q in query,
      select_merge: %{
        struct: q
      }

    repo(opts).all(query)
    |> Enum.map(fn row ->
      column_names = Keyword.get(opts, :columns) |> Keyword.keys()
      columns = Map.take(row, column_names)
      struct = row.struct
      LiveViewDataTable.Item.new_from_data_source(struct, columns)
    end)
  end

  def repo(opts) do
    Keyword.get(opts, :repo)
  end

  def base_query(opts) do
    case Keyword.get(opts, :base_query) do
      nil -> from s in Keyword.get(opts, :schema)
      {module, function} -> apply(module, function, [opts])
    end
  end

  def path_expr(column, opts) do
    Keyword.get(opts, :path, to_string(column))
  end
end
