defmodule BackendWeb.PageController do
  use BackendWeb, :controller

  # Disable layout
  plug :put_layout, false

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
