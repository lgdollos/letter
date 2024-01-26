defmodule LetterWeb.ArticlesLive do
  use LetterWeb, :live_view
  alias Letter.Article
  alias Letter.Articles
  import LetterWeb.ArticleHelpers

  def mount(_url, _session, socket) do
    changeset = Articles.change_article(%Article{})
    {:ok, assign(socket, form: to_form(changeset))}
  end

  def handle_params(%{"filter" => filter}, _session, socket) do
    articles =
      case filter do
        "queue" -> Articles.list_articles("archive", %{is_archived: "n"})
        "archive" -> Articles.list_articles("archive", %{is_archived: "y"})
        "favorites" -> Articles.list_articles("favorites", %{is_favorited: "y"})
        "highlights" -> Articles.list_articles("highlights", nil)
      end

    {:noreply, assign(socket, articles: articles, filter: filter, term: "")}
  end

  def handle_params(_url, _session, socket) do
    articles = Articles.list_articles("archive", %{is_archived: "n"})
    {:noreply, assign(socket, articles: articles, filter: "queue", term: "")}
  end

  def render(assigns) do
    ~H"""
    <div class="grid grid-flow-row grid-cols-12 h-full font-['Khula']">
      <div class="sticky left-0 top-0 col-span-2 row-span-2 h-18 flex dark:bg-zinc-900">
        <img src={~p"/images/letter_logo.png"} class="h-8 w-8 self-center ml-5 h-6" />
      </div>

      <div class="sticky top-0 col-span-10 row-span-2 sm:border-b-0 sm:border-l-0 md:border-l md:border-l-zinc-200 dark:border-l-zinc-700 py-5 pt-6 pl-9 flex flex-row justify-between items-center bg-white dark:bg-zinc-900 md:border-b md:border-b-zinc-200 dark:border-b-zinc-700 z-10">
        <.topbar filter={@filter} term={@term} form={@form} />
      </div>

      <div class="hidden sm:sticky sm:left-0 sm:top-[5.5rem] sm:col-span-2 h-max sm:flex ">
        <.sidebar />
      </div>

      <div class="col-span-10 pt-4 border-l border-zinc-200 dark:border-zinc-700 min-h-screen h-max">
        <.main_feed articles={@articles} />
      </div>
    </div>
    """
  end

  def topbar(assigns) do
    ~H"""
    <div class="">
      <span id="filter_topbar" class="font-bold"><%= @filter |> String.capitalize() %></span>
      <.search_form term={@term} />
    </div>
    <.article_form form={@form} />
    """
  end

  def sidebar(assigns) do
    ~H"""
    <div class="w-full">
      <.sidebar_links filter="queue" />
      <.sidebar_links filter="archive" />
      <.sidebar_links filter="highlights" />
      <.sidebar_links filter="favorites" />
      <.sidebar_links filter="search" />
      <.mode />
    </div>
    """
  end

  def mode(assigns) do
    ~H"""
    <div class="flex flex-row gap-3 justify-start absolute top-[85vh] ml-6">
      <div
        phx-click={change_theme("bg-white")}
        class="border border-gray-700 bg-white dark:text-zinc-900 rounded-full pt-1 px-2 text-sm text-center self-center cursor-pointer"
      >
        L
      </div>
      <div
        phx-click={change_theme("dark")}
        class="border border-black bg-zinc-900 rounded-full pt-1 px-2 text-sm text-center text-indigo-50 self-center cursor-pointer"
      >
        D
      </div>
    </div>
    """
  end

  def search_form(assigns) do
    ~H"""
    <div id="search_form" class="mr-4 hidden">
      <.form phx-submit="search" class="flex flex-row">
        <.input
          name="term"
          value={@term}
          placeholder="Search titles, authors, urls, highlights..."
          autocomplete="off"
          autofocus
          phx-debounce="1000"
          class="mt-0 pb-1 pt-2 px-4 sm:w-[35vw] dark:bg-zinc-900 dark:border-zinc-700 dark:text-indigo-50"
        />
        <.button
          phx-disable-with="Searching..."
          class="sm:bg-white border border-zinc-300 sm:hover:bg-zinc-100 rounded-lg sm:p-1.5 sm:text-black ml-2 sm:px-2.5 dark:bg-zinc-900 dark:border-zinc-700 dark:text-indigo-50 dark:hover:bg-zinc-700"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
            class="w-4 h-4"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607z"
            />
          </svg>
        </.button>
      </.form>
    </div>
    """
  end

  def main_feed(assigns) do
    ~H"""
    <div id="articles" class="ml-4 divide-y divide-y-zinc-200 dark:divide-y-0">
      <.article_row :for={article <- @articles} article={article} />
    </div>
    """
  end

  def article_row(assigns) do
    ~H"""
    <div class="px-5 hover:bg-zinc-100/90 dark:hover:bg-zinc-800 rounded-lg w-full cursor-pointer">
      <div class="flex flex-row justify-between content-center w-full">
        <.link navigate={~p"/article/#{@article.id}"} class="w-11/12">
          <div class="flex flex-col py-5 ">
            <div class="font-semibold text-base"><%= @article.title %></div>
            <div class="flex flex-row">
              <div class="text-sm"><%= @article.author %></div>
              <div class="text-sm ml-2">
                <div></div>
              </div>
            </div>
          </div>
        </.link>
        <div class="hidden sm:flex flex-row gap-5 text-sm align-end content-end justify-end self-center">
          <.article_note_count count={@article.note_count} />
          <.article_actions_bar
            url={@article.url}
            id={@article.id}
            is_archived={@article.is_archived}
            is_favorited={@article.is_favorited}
          />
        </div>
      </div>
    </div>
    """
  end

  def article_form(assigns) do
    ~H"""
    <div id="add_form" class="mr-4 hidden sm:flex">
      <.form for={@form} phx-submit="save" class="flex flex-row">
        <.input
          field={@form[:url]}
          placeholder="Paste a url to save the link"
          autocomplete="off"
          phx-debounce="2000"
          class="mt-0 pb-1 pt-2 px-4 sm:w-[35vw] dark:bg-zinc-900 dark:border-zinc-700 dark:text-indigo-50"
        />
        <.button
          phx-disable-with="Adding..."
          class="sm:bg-white sm:border sm:border-zinc-300 sm:hover:bg-zinc-100 sm:rounded-lg sm:p-1.5 sm:text-black sm:text-xs ml-2 sm:px-2.5 dark:bg-zinc-900 dark:border-zinc-700 dark:text-indigo-50 dark:hover:bg-zinc-700"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
            class="w-4 h-4"
          >
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
          </svg>
        </.button>
      </.form>
    </div>
    """
  end

  def article_note_count(assigns) do
    ~H"""
    <div
      :if={@count && @count > 0}
      class="self-center flex flex-row gap-1.5 justify-center content-center align-center border border-yellow-300 pt-1 rounded-2xl px-3 bg-yellow-100"
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 384 512"
        fill="#7D501F"
        transform="scale(1,-1)"
        class="self-center h-[0.6em] -mt-1"
      >
        <path d="M64 0C28.7 0 0 28.7 0 64V448c0 35.3 28.7 64 64 64H320c35.3 0 64-28.7 64-64V160H256c-17.7 0-32-14.3-32-32V0H64zM256 0V128H384L256 0zM112 256H272c8.8 0 16 7.2 16 16s-7.2 16-16 16H112c-8.8 0-16-7.2-16-16s7.2-16 16-16zm0 64H272c8.8 0 16 7.2 16 16s-7.2 16-16 16H112c-8.8 0-16-7.2-16-16s7.2-16 16-16zm0 64H272c8.8 0 16 7.2 16 16s-7.2 16-16 16H112c-8.8 0-16-7.2-16-16s7.2-16 16-16z" />
      </svg>
      <span class="text-xs text-yellow-800 font-bold self-center"><%= @count %></span>
    </div>
    """
  end

  def article_actions_bar(assigns) do
    ~H"""
    <div class="flex flex-row justify-center content-center align-center">
      <.article_actions
        id={@id}
        url={@url}
        is_favorited={@is_favorited}
        is_archived={@is_archived}
        n={4}
        ref="feed"
      />
    </div>
    """
  end

  def handle_event("save", %{"article" => article}, socket) do
    params = new_article(article)

    case Articles.create_article(params) do
      {:ok, _} -> {:noreply, push_navigate(socket, to: ~p"/queue")}
      {:error, changeset} -> {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("archive", %{"id" => id}, socket) do
    article = id |> String.to_integer() |> Articles.get_article!()
    Articles.update_article(article, %{is_archived: y_or_n(article.is_archived)})
    Articles.update_note_count(id)

    {:noreply, push_patch(socket, to: ~p"/queue", replace: true)}
  end

  def handle_event("redirect", %{"url" => url}, socket) do
    {:noreply, redirect(socket, to: url)}
  end

  def handle_event("favorite", %{"id" => id}, socket) do
    article = id |> String.to_integer() |> Articles.get_article!()
    Articles.update_article(article, %{is_favorited: y_or_n(article.is_favorited)})
    Articles.update_note_count(id)

    {:noreply, push_patch(socket, to: ~p"/favorites", replace: true)}
  end

  def handle_event("search", %{"term" => term}, socket) do
    articles = Articles.search_articles("%#{String.trim(term)}%")
    {:noreply, assign(socket, articles: articles, term: "")}
  end

  defp new_article(article) do
    content = parse(article["url"])

    article
    |> Map.put("title", content.title)
    |> Map.put("author", List.first(content.authors || [], get_domain(article["url"])))
    |> Map.put("is_archived", "n")
    |> Map.put("is_favorited", "n")
    |> Map.put("note_count", 0)
  end
end
