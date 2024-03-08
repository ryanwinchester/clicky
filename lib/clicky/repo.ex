defmodule Clicky.Repo do
  use Ecto.Repo,
    otp_app: :clicky,
    adapter: Ecto.Adapters.Postgres
end
