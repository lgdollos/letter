defmodule Letter.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      LetterWeb.Telemetry,
      # Start the Ecto repository
      Letter.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Letter.PubSub},
      # Start Finch
      {Finch, name: Letter.Finch},
      # Start the Endpoint (http/https)
      LetterWeb.Endpoint
      # Start a worker by calling: Letter.Worker.start_link(arg)
      # {Letter.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Letter.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LetterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
