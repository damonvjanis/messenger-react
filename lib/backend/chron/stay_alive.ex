defmodule Backend.Chron.StayAlive do
  use GenServer

  @url Application.get_env(:backend, :url)

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    if String.contains?(@url, "localhost") do
      :ignore
    else
      schedule_work()

      {:ok, state}
    end
  end

  def handle_info(:work, state) do
    Mojito.get("http://#{@url}")

    schedule_work()

    {:noreply, state}
  end

  defp schedule_work do
    # Every minute
    Process.send_after(self(), :work, 60 * 1000)
  end
end
