defmodule Mix.Tasks.Cloudinary do
  use Mix.Task

  def run(_) do
    Application.ensure_all_started(:backend)

    cloudinary_url = Application.get_env(:backend, :cloudinary_url)

    api_key = api_key(cloudinary_url)
    api_secret = api_secret(cloudinary_url)
    cloud_name = cloud_name(cloudinary_url)

    url = "https://#{api_key}:#{api_secret}@api.cloudinary.com/v1_1/#{cloud_name}/upload_presets"
    headers = [{"Content-Type", "application/json"}]
    data = Jason.encode!(%{name: "attachments", unsigned: true})

    Mojito.post(url, headers, data)
  end

  defp api_key(url) do
    url
    |> String.split("cloudinary://")
    |> List.last()
    |> String.split(":")
    |> List.first()
  end

  defp api_secret(url) do
    url
    |> String.split(":")
    |> List.last()
    |> String.split("@")
    |> List.first()
  end

  defp cloud_name(url) do
    url
    |> String.split("@")
    |> List.last()
  end
end
