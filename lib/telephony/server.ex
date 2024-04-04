defmodule Telephony.Server do
  @behaviour GenServer
  alias Telephony.Core

  def start_link(server_name) do
    GenServer.start_link(__MODULE__, [], name: server_name)
  end

  def init(subscribers) do
    {:ok, subscribers}
  end

  def handle_call({:create_subscriber, payload}, _from, subscribers) do
    case Core.create_subscriber(subscribers, payload) do
      {:error, _message} = err -> {:reply, err, subscribers}
      subscribers -> {:reply, subscribers, subscribers}
    end
  end

  def handle_call({:search_subscriber, phone_number}, _from, subscribers) do
    subscriber = Core.search_subscriber(subscribers, phone_number)
    {:reply, subscriber, subscribers}
  end

  def handle_cast({:make_recharge, phone_number, value}, subscribers) do
    case Core.make_recharge(subscribers, phone_number, value) do
      {:error, _message} -> {:noreply, subscribers}
      {subscribers, _subscriber} -> {:noreply, subscribers}
    end
  end
end
