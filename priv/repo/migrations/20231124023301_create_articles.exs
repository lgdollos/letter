defmodule Letter.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add :url, :string
      add :title, :string
      add :author, :string
      add :note_count, :integer

      timestamps()
    end
  end
end
