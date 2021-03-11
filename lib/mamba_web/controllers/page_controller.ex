defmodule MambaWeb.PageController do
  use MambaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
