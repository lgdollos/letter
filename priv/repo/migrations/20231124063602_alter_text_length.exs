defmodule Letter.Repo.Migrations.AlterTextLength do
  use Ecto.Migration

  def change do
    alter table(:notes) do
      modify :text, :text
    end
  end
end
