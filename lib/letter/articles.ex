defmodule Letter.Articles do
  import Ecto.Query, warn: false
  alias Letter.Repo
  alias Letter.Article
  alias Letter.Note
  alias Letter.Notes

  def create_article(attrs \\ %{}) do
    %Article{}
    |> Article.changeset(attrs)
    |> Repo.insert()
  end

  def change_article(%Article{} = article, attrs \\ %{}) do
    Article.changeset(article, attrs)
  end

  def list_articles() do
    Repo.all(Article)
  end

  def list_articles(type, filter) do
    article =
      case type do
        "archive" -> filter_by_archived(Article, filter)
        "favorites" -> filter_by_favorited(Article, filter)
        "highlights" -> filter_by_highlighted(Article, nil)
      end

    article
    |> order_by([a], desc: a.updated_at)
    |> Repo.all()
  end

  def get_article!(id) do
    Repo.get!(Article, id)
  end

  def update_article(%Article{} = article, attrs) do
    article
    |> Article.changeset(attrs)
    |> Repo.update()
  end

  defp filter_by_archived(query, %{is_archived: is_archived}) do
    where(query, is_archived: ^is_archived)
  end

  defp filter_by_favorited(query, %{is_favorited: is_favorited}) do
    where(query, is_favorited: ^is_favorited)
  end

  defp filter_by_highlighted(query, _) do
    where(query, [a], a.note_count > 1 and not is_nil(a.note_count))
  end

  def count_articles do
    Article
    |> Repo.all()
    |> length
  end

  def update_note_count(id) do
    article = get_article!(id)
    count = Notes.count_notes(id)
    update_article(article, %{note_count: count})
  end

  def update_articles_note_count() do
    Enum.to_list(1..count_articles())
    |> Enum.map(fn a -> update_note_count(a) end)
  end

  def search_articles(term) do
    query = from(s in subquery(note_query(term)), order_by: [desc: s.note_count])
    Repo.all(query)
  end

  defp article_query(term) do
    from(a in Article,
      where:
        like(fragment("lower(?)", a.title), ^term) or
          like(fragment("lower(?)", a.url), ^term) or
          like(fragment("lower(?)", a.author), ^term),
      select: a
    )
  end

  defp note_query(term) do
    aq = article_query(term)

    from(n in Note,
      where: like(fragment("lower(?)", n.text), ^term),
      join: a in Article,
      on: n.article_id == a.id,
      select: a,
      union: ^aq
    )
  end
end
