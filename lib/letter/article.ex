defmodule Letter.Article do
  use Ecto.Schema
  import Ecto.Changeset

  schema "articles" do
    field :url, :string
    field :title, :string
    field :author, :string
    field :is_archived, :string
    field :is_favorited, :string
    field :thumbnail, :string
    field :note_count, :integer

    timestamps()
  end

  def changeset(article, attrs) do
    article
    |> cast(attrs, [:url, :title, :author, :is_archived, :is_favorited, :note_count])
    |> validate_required([:url, :title])
  end
end
