defmodule BackendWeb.Authentication do
  @behaviour Plug

  alias BackendWeb.Endpoint

  import Plug.Conn

  @salt "AtBlG6R9"

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, :valid} <- Phoenix.Token.verify(Endpoint, @salt, token, max_age: 86400) do
      Absinthe.Plug.put_options(conn, context: %{authenticated?: true})
    else
      _ -> conn
    end
  end

  def verify_token(token) when is_binary(token) do
    Phoenix.Token.verify(Endpoint, @salt, token, max_age: 86400)
  end

  def create_token, do: Phoenix.Token.sign(Endpoint, @salt, :valid)
end
