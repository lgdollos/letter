defmodule Letter.Repo.Migrations.CreateNotes do
  use Ecto.Migration

  def change do
    create table(:notes) do
      add :type, :string
      add :text, :string
      add :formatting, :string
      add :article_id, references(:articles, on_delete: :nothing)

      timestamps()
    end

    create index(:notes, [:article_id])
  end
end
