defmodule Backend.Emails do
  @key Application.get_env(:backend, :mailgun_api_key)
  @domain Application.get_env(:backend, :mailgun_domain)
  @to Application.get_env(:backend, :notification_email)
  @url Application.get_env(:backend, :url)
  @headers [{"content-type", "application/x-www-form-urlencoded"}]

  def notification() do
    url = "https://api:#{@key}@api.mailgun.net/v3/#{@domain}/messages"
    from = "Messenger <no-reply@#{@domain}>"
    subject = "New messages"
    text = "Please log in to https://#{@url} to view new messages"

    query = %{"from" => from, "to" => @to, "subject" => subject, "text" => text}

    Mojito.post(url, @headers, URI.encode_query(query))
  end
end
