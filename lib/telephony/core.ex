defmodule Telephony.Core do
  @moduledoc false
  alias __MODULE__.Subscriber
  @types [:prepaid, :postpaid]

  def create_subscriber(subscribers, %{type: type} = payload)
      when type in @types do
    case Enum.find(subscribers, &(&1.phone_number == payload.phone_number)) do
      nil ->
        subscriber = Subscriber.new(payload)
        subscribers ++ [subscriber]

      subscriber ->
        {:error, "Subscriber `#{subscriber.phone_number}`, already exists"}
    end
  end

  def create_subscriber(_subscribers, _payload),
    do: {:error, "Only 'prepaid' or 'postpaid' are accepted"}

  def search_subscriber(subscribers, phone_number) do
    Enum.find(subscribers, &(&1.phone_number == phone_number))
  end

  def make_recharge(subscribers, phone_number, value) do
    perform = fn subscriber ->
      subscribers = List.delete(subscribers, subscriber)
      result = Subscriber.make_recharge(subscriber, value, Date.utc_today())
      update_subscriber(subscribers, result)
    end

    execute_operation(subscribers, phone_number, perform)
  end

  def make_call(subscribers, phone_number, time_spent) do
    perform = fn subscriber ->
      subscribers = List.delete(subscribers, subscriber)
      result = Subscriber.make_call(subscriber, time_spent, Date.utc_today())
      update_subscriber(subscribers, result)
    end

    execute_operation(subscribers, phone_number, perform)
  end

  def print_invoice(subscribers, phone_number, year, month) do
    perform = &Subscriber.print_invoice(&1, year, month)
    execute_operation(subscribers, phone_number, perform)
  end

  def print_invoices(subscribers, year, month) do
    Enum.map(subscribers, &Subscriber.print_invoice(&1, year, month))
  end

  defp execute_operation(subscribers, phone_number, fun) do
    subscribers
    |> search_subscriber(phone_number)
    |> then(fn subscriber ->
      if is_nil(subscriber) do
        subscribers
      else
        fun.(subscriber)
      end
    end)
  end

  defp update_subscriber(subscribers, {:error, _message} = err) do
    {subscribers, err}
  end

  defp update_subscriber(subscribers, subscriber) do
    {subscribers ++ [subscriber], subscriber}
  end
end
