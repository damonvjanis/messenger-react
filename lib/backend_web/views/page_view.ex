defmodule BackendWeb.PageView do
  use BackendWeb, :view

  def render("index.html", _assigns) do
    Path.join(:code.priv_dir(:backend) |> IO.inspect(), "static/build/index.html")
    |> IO.inspect()
    |> File.read!()
    |> IO.inspect()
    |> raw()
    |> IO.inspect()
  end
end
