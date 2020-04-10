defmodule BackendWeb.Resolvers do
  def format_changeset_errors(errors) do
    for {field, {message, _}} <- errors do
      %{message: message, field: field}
    end
  end
end
