defmodule Letter.Notes do
  import Ecto.Query, warn: false
  alias Letter.Repo
  alias Letter.Note

  def create_note(attrs \\ %{}) do
    %Note{}
    |> Note.changeset(attrs)
    |> Repo.insert()
  end

  def change_note(%Note{} = note, attrs \\ %{}) do
    Note.changeset(note, attrs)
  end

  def list_notes(id) do
    query =
      from i in Note,
        where: i.article_id == ^id,
        select: i.text

    Repo.all(query)
  end

  def get_note!(id) do
    Repo.get!(Note, id)
  end

  def count_notes(id) do
    Note
    |> where([h], h.article_id == ^id)
    |> select([h], count(h.inserted_at, :distinct))
    |> Repo.all()
    |> List.first()
  end
end
