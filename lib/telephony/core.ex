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
end
