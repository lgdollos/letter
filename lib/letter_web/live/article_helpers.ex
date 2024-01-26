defmodule LetterWeb.ArticleHelpers do
  use LetterWeb, :live_view

  def parse(url) do
    Readability.summarize(url)
  end

  def sidebar_icons() do
    %{
      "Queue" =>
        "M6 6.878V6a2.25 2.25 0 012.25-2.25h7.5A2.25 2.25 0 0118 6v.878m-12 0c.235-.083.487-.128.75-.128h10.5c.263 0 .515.045.75.128m-12 0A2.25 2.25 0 004.5 9v.878m13.5-3A2.25 2.25 0 0119.5 9v.878m0 0a2.246 2.246 0 00-.75-.128H5.25c-.263 0-.515.045-.75.128m15 0A2.25 2.25 0 0121 12v6a2.25 2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 18v-6c0-.98.626-1.813 1.5-2.122",
      "Archive" =>
        "M20.25 7.5l-.625 10.632a2.25 2.25 0 01-2.247 2.118H6.622a2.25 2.25 0 01-2.247-2.118L3.75 7.5M10 11.25h4M3.375 7.5h17.25c.621 0 1.125-.504 1.125-1.125v-1.5c0-.621-.504-1.125-1.125-1.125H3.375c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125z",
      "Favorites" =>
        "M11.48 3.499a.562.562 0 011.04 0l2.125 5.111a.563.563 0 00.475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 00-.182.557l1.285 5.385a.562.562 0 01-.84.61l-4.725-2.885a.563.563 0 00-.586 0L6.982 20.54a.562.562 0 01-.84-.61l1.285-5.386a.562.562 0 00-.182-.557l-4.204-3.602a.563.563 0 01.321-.988l5.518-.442a.563.563 0 00.475-.345L11.48 3.5z",
      "Highlights" =>
        "M16.862 4.487l1.687-1.688a1.875 1.875 0 112.652 2.652L6.832 19.82a4.5 4.5 0 01-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 011.13-1.897L16.863 4.487zm0 0L19.5 7.125",
      "Search" => "M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607z",
      "Archived" =>
        "M17.593 3.322c1.1.128 1.907 1.077 1.907 2.185V21L12 17.25 4.5 21V5.507c0-1.108.806-2.057 1.907-2.185a48.507 48.507 0 0111.186 0z",
      "Favorited" =>
        "M10.788 3.21c.448-1.077 1.976-1.077 2.424 0l2.082 5.007 5.404.433c1.164.093 1.636 1.545.749 2.305l-4.117 3.527 1.257 5.273c.271 1.136-.964 2.033-1.96 1.425L12 18.354 7.373 21.18c-.996.608-2.231-.29-1.96-1.425l1.257-5.273-4.117-3.527c-.887-.76-.415-2.212.749-2.305l5.404-.433 2.082-5.006z",
      "Redirect" =>
        "M464 256A208 208 0 1 0 48 256a208 208 0 1 0 416 0zM0 256a256 256 0 1 1 512 0A256 256 0 1 1 0 256zm306.7 69.1L162.4 380.6c-19.4 7.5-38.5-11.6-31-31l55.5-144.3c3.3-8.5 9.9-15.1 18.4-18.4l144.3-55.5c19.4-7.5 38.5 11.6 31 31L325.1 306.7c-3.2 8.5-9.9 15.1-18.4 18.4zM288 256a32 32 0 1 0 -64 0 32 32 0 1 0 64 0z"
    }
  end

  def sidebar_links(assigns) do
    ~H"""
    <.link :if={@filter != "search"} navigate={~p"/#{@filter}"}>
      <.sidebar_stuff filter={@filter} />
    </.link>

    <.link :if={@filter == "search"} phx-click={toggle_search()}>
      <.sidebar_stuff filter={@filter} />
    </.link>
    """
  end

  def sidebar_stuff(assigns) do
    ~H"""
    <div class="mb-1 mx-2 flex flex-row px-3 py-1 pt-2 cursor-pointer hover:bg-zinc-100/90 dark:hover:bg-zinc-800 rounded-lg justify-start align-center">
      <svg
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
        stroke-width="1.5"
        stroke="currentColor"
        class="w-5 h-5"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          d={sidebar_icons()[String.capitalize(@filter)]}
        />
      </svg>
      <div class="ml-2"><%= String.capitalize(@filter) %></div>
    </div>
    """
  end

  def get_domain(url) do
    # TODO: regex?
    url
    |> String.split("//")
    |> List.last()
    |> String.split("/")
    |> List.first()
    |> String.split("www.")
    |> List.last()
  end

  def article_actions(assigns) do
    ~H"""
    <%!-- archive --%>
    <.link class="self-center" phx-click="archive" phx-value-id={@id}>
      <div class="rounded-md hover:bg-zinc-200 dark:hover:bg-zinc-800 p-1.5">
        <svg
          :if={@is_archived == "n"}
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class={"h-#{@n}"}
        >
          <path stroke-linecap="round" stroke-linejoin="round" d={sidebar_icons()["Archive"]} />
        </svg>

        <svg
          :if={@is_archived == "y"}
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class={"h-#{@n}"}
        >
          <path stroke-linecap="round" stroke-linejoin="round" d={sidebar_icons()["Archived"]} />
        </svg>
      </div>
    </.link>

    <%!-- url --%>
    <.link href={@url} class="self-center" target="_blank" rel="noopener noreferrer">
      <div class="rounded-md hover:bg-zinc-200 dark:hover:bg-zinc-800 p-1.5">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          height="1em"
          viewBox="0 0 512 512"
          class="dark:fill-zinc-300"
        >
          <path d={sidebar_icons()["Redirect"]} />
        </svg>
      </div>
    </.link>

    <%!-- favorite --%>
    <.link class="self-center" phx-click="favorite" phx-value-id={@id}>
      <div class="rounded-md hover:bg-zinc-200 dark:hover:bg-zinc-800 p-1.5">
        <svg
          :if={@is_favorited == "n"}
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class={"h-#{@n}"}
        >
          <path stroke-linecap="round" stroke-linejoin="round" d={sidebar_icons()["Favorites"]} />
        </svg>

        <svg
          :if={@is_favorited == "y"}
          mlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          stroke="#DAB549"
          class={"h-#{@n} fill-yellow-400"}
        >
          <path fill-rule="evenodd" d={sidebar_icons()["Favorited"]} clip-rule="evenodd" />
        </svg>
      </div>
    </.link>

    <%!-- customize --%>
    <.link :if={@ref == "content"} phx-click={toggle_settings()}>
      <div class="rounded-md hover:bg-zinc-200 dark:hover:bg-zinc-800 pl-1.5 py-1">
        <span class="">Aa</span>
      </div>
    </.link>
    """
  end

  def toggle_search do
    JS.toggle(to: "#search_form")
    |> JS.toggle(to: "#filter_topbar")
    |> JS.toggle(to: "#add_form")
  end

  def toggle_settings do
    JS.toggle(to: "#settings")
  end

  def y_or_n(x) do
    case x do
      "y" -> "n"
      "n" -> "y"
    end
  end

  def format_html(html) do
    html
    |> String.replace("&amp;", fn _ -> "&" end)
    |> String.replace("&nbsp;", fn _ -> " " end)
  end

  def change_theme(theme) do
    tag = "html"
    remove = "bg-white bg-[#F7F1E4] dark" |> String.replace(theme, "") |> String.trim()

    JS.remove_class(remove, to: tag) |> JS.add_class(theme, to: tag)
  end
end
