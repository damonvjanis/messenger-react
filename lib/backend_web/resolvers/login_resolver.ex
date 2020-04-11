defmodule BackendWeb.Resolvers.LoginResolver do
  alias BackendWeb.Authentication
  require Logger

  def login(%{code: code}, _) do
    if code == System.get_env("LOGIN_CODE") do
      {:ok, %{token: Authentication.create_token()}}
    else
      {:ok, %{}}
    end
  end

  def is_logged_in(_, %{context: %{authenticated?: true}}) do
    {:ok, %{is_logged_in: true}}
  end

  def is_logged_in(_, _) do
    {:ok, %{is_logged_in: false}}
  end
end
