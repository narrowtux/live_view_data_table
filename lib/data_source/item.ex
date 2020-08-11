defmodule LiveViewDataTable.Item do
  @type t :: %__MODULE__{
    changeset: Ecto.Changeset.t() | nil,
    columns: [{atom(), term()}],
    struct: struct()
  }

  defstruct [
    changeset: nil,
    columns: [],
    struct: nil,
    id: nil
  ]

  @spec new_from_data_source(struct(), [{atom(), term()}]) :: t()
  def new_from_data_source(struct, columns) do
    %__MODULE__{struct: struct, columns: columns, id: Ecto.UUID.autogenerate()}
  end

  @spec with_changeset(t()) :: t()
  def with_changeset(item) do
    changeset = Ecto.Changeset.change(item.struct)
    %{ item | changeset: changeset }
  end
end
