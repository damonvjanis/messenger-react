defmodule BackendWeb.PageView do
  use BackendWeb, :view

  def render("index.html", _assigns) do
    Path.join(:code.priv_dir(:backend), "static/build/index.html")
    |> File.read!()
    |> raw()
  end
end
