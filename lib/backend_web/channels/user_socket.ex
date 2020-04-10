defmodule BackendWeb.UserSocket do
  use Phoenix.Socket

  use Absinthe.Phoenix.Socket,
    schema: BackendWeb.Schema

  alias BackendWeb.Authentication

  ## Channels
  # channel "room:*", BackendWeb.RoomChannel

  def connect(_params = %{"token" => token}, socket, _) do
    case Authentication.verify_token(token) do
      {:ok, :valid} -> {:ok, socket}
      {:error, _} -> :error
    end
  end

  def connect(_params, _socket, _connect_info), do: :error

  def id(_socket), do: nil
end
