defprotocol Subscriber do
  def print_invoice(subsriber_type, calls, year, month)
  def make_call(subscriber_type, time_spent, date)
  def make_recharge(subscriber_type, value, date)
end

defmodule Telephony.Core.Subscriber do
  @moduledoc false
  alias Telephony.Core.{Postpaid, Prepaid}

  defstruct full_name: nil, phone_number: nil, subscriber_type: :prepaid, calls: []

  def new(%{subscriber_type: :prepaid} = payload) do
    payload = %{payload | subscriber_type: %Prepaid{}}
    struct(__MODULE__, payload)
  end

  def new(%{subscriber_type: :postpaid} = payload) do
    payload = %{payload | subscriber_type: %Postpaid{}}
    struct(__MODULE__, payload)
  end

  def make_call(subscriber, time_spent, date) do
    case Subscriber.make_call(subscriber.subscriber_type, time_spent, date) do
      {:error, message} -> {:error, message}
      {type, call} -> %{subscriber | subscriber_type: type, calls: subscriber.calls ++ [call]}
    end
  end
end
