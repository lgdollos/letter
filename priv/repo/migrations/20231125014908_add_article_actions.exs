defmodule Letter.Repo.Migrations.AddArticleActions do
  use Ecto.Migration

  def change do
    alter table(:articles) do
      add :is_archived, :string
      add :is_favorited, :string
      add :thumbnail, :string
    end
  end
end
