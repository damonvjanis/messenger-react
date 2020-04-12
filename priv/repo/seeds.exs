# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Backend.Repo.insert!(%Backend.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Backend.Repo
alias Backend.Conversations.Conversation
alias Backend.Conversations.Message

base_number = number = 8_011_111_111

random_words = ["the", "quick", "brown", "fox", "jumps", "over", "the", "lazy", "dog"]

send_statuses = ["sending", "sent", "failed", "delivered"]

Enum.each(1..10, fn increment ->
  number = "+1" <> to_string(base_number + increment)

  conversation = Repo.insert!(%Conversation{number: number})

  Enum.each(1..10, fn _ ->
    body =
      1..9
      |> Enum.map(fn _ -> Enum.random(random_words) end)
      |> Enum.join(" ")

    direction = Enum.random(["inbound", "outbound"])

    data = %Message{
      body: body,
      direction: direction,
      type: "text",
      status: if(direction == "inbound", do: "received", else: Enum.random(send_statuses)),
      conversation_id: conversation.id
    }

    Repo.insert!(data)
  end)
end)
