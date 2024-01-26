defmodule Letter.Note do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notes" do
    field :type, :string
    field :text, :string
    field :formatting, :string
    field :article_id, :id

    timestamps()
  end

  def changeset(note, attrs) do
    note
    |> cast(attrs, [:type, :text, :formatting, :article_id])
    |> validate_required([:text, :article_id])
  end
end
