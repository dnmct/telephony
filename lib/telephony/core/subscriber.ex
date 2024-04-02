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

  def make_call(%{subscriber_type: %Postpaid{}} = subscriber, time_spent, date) do
    Postpaid.make_call(subscriber, time_spent, date)
  end

  def make_call(%{subscriber_type: %Prepaid{}} = subscriber, time_spent, date) do
    Prepaid.make_call(subscriber, time_spent, date)
  end

  def make_recharge(%{subscriber_type: %Prepaid{}} = subscriber, value, date) do
    Prepaid.make_recharge(subscriber, value, date)
  end

  def make_recharge(_subscriber, _value, _date) do
    {:error, "Only prepaid subscribers can make recharges"}
  end
end
