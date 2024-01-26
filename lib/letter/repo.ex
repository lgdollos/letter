defmodule Letter.Repo do
  use Ecto.Repo,
    otp_app: :letter,
    adapter: Ecto.Adapters.Postgres
end
