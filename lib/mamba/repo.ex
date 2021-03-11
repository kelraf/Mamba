defmodule Mamba.Repo do
  use Ecto.Repo,
    otp_app: :mamba,
    adapter: Ecto.Adapters.Postgres
end
