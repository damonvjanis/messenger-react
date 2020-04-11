defmodule Backend.Chron.MissedMessages do
  use GenServer

  alias Backend.Conversations
  alias Backend.Emails
  alias Backend.Conversations.Conversation

  import Ecto.Query, only: [from: 2]

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
    now = NaiveDateTime.utc_now()
    ten_ago = NaiveDateTime.add(now, -1 * 60 * 10)
    query = from(c in Conversation, where: c.unread_at < ^ten_ago)

    conversations = Conversations.list_conversations(query: query)

    if conversations != [] do
      Emails.notification()

      # Set unread to nil to avoid repeats
      Enum.each(conversations, &Conversations.update_conversation(&1, %{unread_at: nil}))
    end

    schedule_work()

    {:noreply, state}
  end

  defp schedule_work do
    # Every minute
    Process.send_after(self(), :work, 60 * 1000)
  end
end
