defprotocol Subscriber do
  def print_invoice(subsriber_type, calls, year, month)
  def make_call(type, time_spent, date)
  def make_recharge(type, value, date)
end

defmodule Telephony.Core.Subscriber do
  @moduledoc false
  alias Telephony.Core.{Postpaid, Prepaid}

  defstruct full_name: nil, phone_number: nil, type: :prepaid, calls: []

  def new(%{type: :prepaid} = payload) do
    payload = %{payload | type: %Prepaid{}}
    struct(__MODULE__, payload)
  end

  def new(%{type: :postpaid} = payload) do
    payload = %{payload | type: %Postpaid{}}
    struct(__MODULE__, payload)
  end

  def make_call(subscriber, time_spent, date) do
    case Subscriber.make_call(subscriber.type, time_spent, date) do
      {:error, message} -> {:error, message}
      {type, call} -> %{subscriber | type: type, calls: subscriber.calls ++ [call]}
    end
  end
end
