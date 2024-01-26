defmodule LetterWeb.ArticleLive do
  use LetterWeb, :live_view
  alias Letter.Note
  alias Letter.Notes
  alias Letter.Articles
  import LetterWeb.ArticleHelpers

  def mount(_url, _session, socket) do
    changeset = Notes.change_note(%Note{})
    {:ok, assign(socket, changeset: changeset, mark_type: "u")}
  end

  def handle_params(%{"id" => id}, _session, socket) do
    article = Articles.get_article!(id)
    %{article_html: html} = parse(article.url)
    %{id: id} = article

    highlights = Notes.list_notes(id)
    count = Notes.count_notes(id)

    {:noreply,
     assign(socket, html: html, article: article, highlights: highlights, id: id, count: count)}
  end

  def render(assigns) do
    ~H"""
    <div class="article flex flex-row w-full absolute left-0" id="page">
      <.side article={@article} />
      <.main
        html={@html}
        changeset={@changeset}
        highlights={@highlights}
        article={@article}
        count={@count}
        mark_type={@mark_type}
      />
    </div>
    """
  end

  def side(assigns) do
    ~H"""
    <div class="absolute h-full ml-4">
      <.home id={@article.id} />
      <div class="border border-transparent hover:border-zinc-300 dark:hover:border-zinc-700 sm:sticky sm:flex sm:flex-row sm:top-[35vh] sm:rounded-md sm:py-2.5 sm:pl-1 sm:w-[2.5rem]">
        <.actions article={@article} />
      </div>
      <.settings />
    </div>
    """
  end

  def main(assigns) do
    ~H"""
    <div
      class="self-center lg:ml-[32vw] sm:w-[50vw] lg:w-[35vw] mb-16 z-0"
      id="main"
      phx-hook="Marker"
    >
      <div class="mb-10">
        <h1 class="text-xl font-['Khula'] font-bold"><%= @article.title %></h1>
        <span class="text-base font-['Khula']"><%= @article.author %></span>
      </div>

      <div id="content" class="font-default">
        <%= @html |> format_html() |> format_highlight(@highlights, @mark_type) |> raw() %>
      </div>
    </div>
    """
  end

  def home(assigns) do
    ~H"""
    <.link phx-click="home" phx-value-id={@id}>
      <div class="sticky top-4 left-0 border border-zinc-300 dark:border-zinc-700 hover:bg-zinc-100 dark:hover:bg-zinc-800 rounded-lg p-1.5 w-[2rem]">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="w-4 h-4"
        >
          <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5L8.25 12l7.5-7.5" />
        </svg>
      </div>
    </.link>
    """
  end

  def actions(assigns) do
    ~H"""
    <div class="side flex flex-col justify-center content-center align-center gap-3">
      <.article_actions
        id={@article.id}
        url={@article.url}
        is_favorited={@article.is_favorited}
        is_archived={@article.is_archived}
        n={5}
        ref="content"
      />
    </div>
    """
  end

  def settings(assigns) do
    ~H"""
    <div
      class="hidden border border-zinc-300 dark:border-zinc-700 top-[50.3vh] px-4 py-1 ml-12 rounded-md sticky font-['Khula'] divide-y divide-y-zinc-200 dark:divide-y-0"
      id="settings"
      phx-click-away={toggle_settings()}
    >
      <div class="py-3 flex flex-row">
        <span class="font-semibold text-zinc-600 dark:text-zinc-300">Theme</span>
        <div class="flex flex-row gap-3 ml-10 content-center align-center justify-start">
          <div
            phx-click={change_theme("bg-white")}
            class="border border-gray-700 bg-white dark:text-zinc-900 rounded pt-1 px-2 text-sm text-center self-center cursor-pointer"
          >
            Light
          </div>
          <div
            phx-click={change_theme("bg-[#F7F1E4]")}
            class="border border-yellow-700 bg-[#F7F1E4] dark:text-zinc-900 rounded pt-1 px-2 text-sm text-center self-center cursor-pointer"
          >
            Sepia
          </div>
          <div
            phx-click={change_theme("dark")}
            class="border border-black bg-zinc-900 rounded pt-1 px-2 text-sm text-center text-indigo-50 self-center cursor-pointer"
          >
            Dark
          </div>
        </div>
      </div>
      <div class="py-3 flex flex-row">
        <span class="font-semibold text-zinc-600 dark:text-zinc-300">Font</span>
        <div class="flex flex-col gap-3 ml-14 -mt-0.5">
          <div class="cursor-pointer" phx-click={change_font("font-default")}>
            <span class="font-default">Literata</span>
          </div>
          <div class="cursor-pointer" phx-click={change_font("font-serif")}>
            <span class="font-serif">Source Serif</span>
          </div>
          <div class="cursor-pointer" phx-click={change_font("font-sans")}>
            <span class="font-sans">Plex Sans</span>
          </div>
        </div>
      </div>
      <div class="py-3 flex flex-row">
        <span class="font-semibold text-zinc-600 dark:text-zinc-300">Highlight</span>
        <div class="flex flex-row gap-3 ml-6 content-center align-center justify-start">
          <div
            class="flex circle w-[24px] h-[24px] bg-gray-100 border border-gray-300 rounded-full justify-center items-center cursor-pointer"
            phx-click={change_mark("u")}
          >
            <span class="underline decoration-solid decoration-[#D74B40] decoration-2 text-black text-base">
              A
            </span>
          </div>
          <div
            class="circle w-[22px] h-[22px] bg-yellow-300 rounded-full cursor-pointer"
            phx-click={change_mark("y")}
          >
          </div>
          <div
            class="circle w-[22px] h-[22px] bg-[#BCABEF] rounded-full cursor-pointer"
            phx-click={change_mark("v")}
          >
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("mark", text, socket) do
    notes =
      text
      |> split_html()
      |> Enum.map(fn n -> n |> new_note(socket.assigns.id) |> save_note(socket) end)

    changeset = Notes.change_note(%Note{})

    socket =
      socket
      |> assign(changeset: changeset)
      |> update(:highlights, fn h -> Enum.concat(notes, h) end)

    {:noreply, socket}
  end

  def handle_event("archive", %{"id" => id}, socket) do
    article = id |> String.to_integer() |> Articles.get_article!()
    Articles.update_article(article, %{is_archived: y_or_n(article.is_archived)})
    Articles.update_note_count(id)

    {:noreply, push_navigate(socket, to: ~p"/queue")}
  end

  def handle_event("favorite", %{"id" => id}, socket) do
    article = id |> String.to_integer() |> Articles.get_article!()
    Articles.update_article(article, %{is_favorited: y_or_n(article.is_favorited)})
    Articles.update_note_count(id)

    {:noreply, push_navigate(socket, to: ~p"/article/#{id}", replace: true)}
  end

  def handle_event("home", %{"id" => id}, socket) do
    article = id |> String.to_integer() |> Articles.get_article!()
    Articles.update_note_count(id)

    {:noreply, push_navigate(socket, to: ~p"/queue")}
  end

  def new_note(text, id) do
    %{text: String.trim(text)}
    |> Map.put(:type, "h")
    |> Map.put(:formatting, "")
    |> Map.put(:article_id, id)
  end

  def save_note(params, socket) do
    case Notes.create_note(params) do
      {:ok, note} ->
        Articles.update_article(socket.assigns.article, %{note_count: socket.assigns.count + 1})
        note.text

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def format_highlight(html, highlights, mark_type) do
    String.replace(html, highlights, fn h -> "<span class=\"h #{mark_type}\">#{h}</span>" end)
  end

  def split_html(html) do
    Floki.parse_document!(html)
    |> Floki.text(sep: "\t")
    |> String.split("\t")
    |> Enum.filter(fn x -> not Enum.member?(out(), String.trim(x)) end)
  end

  def out do
    [".", ",", "...", "!", "?", ":", "\\'"]
    |> Enum.concat(Enum.to_list(0..9) |> Enum.map(fn n -> to_string(n) end))
  end

  def change_mark(mark) do
    tag = "#content .h"
    remove = "u y v" |> String.replace(mark, "") |> String.trim()

    JS.remove_class(remove, to: tag) |> JS.add_class(mark, to: tag)
  end

  def change_font(font) do
    tag = "#content"
    remove = "font-serif font-sans font-default" |> String.replace(font, "") |> String.trim()

    JS.remove_class(remove, to: tag) |> JS.add_class(font, to: tag)
  end
end
