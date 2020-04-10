defmodule BackendWeb.Router do
  use BackendWeb, :router

  alias BackendWeb.Authentication

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug(Authentication)
  end

  pipeline :telnyx do
    plug :accepts, ["json"]
  end

  scope "/api" do
    pipe_through :api

    forward("/", Absinthe.Plug, schema: BackendWeb.Schema)
  end

  scope "/telnyx", BackendWeb do
    pipe_through(:telnyx)

    post("/inbound", MessageController, :inbound)
    post("/status", MessageController, :status)
  end

  scope "/", BackendWeb do
    pipe_through :browser

    get "/*path", PageController, :index
  end
end
