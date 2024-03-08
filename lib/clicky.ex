defmodule Clicky do
  @moduledoc """
  Clicky keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def broadcast(topic, message) do
    Phoenix.PubSub.broadcast(Clicky.PubSub, topic, message)
  end

  def subscribe(topic) do
    Phoenix.PubSub.subscribe(Clicky.PubSub, topic)
  end
end
