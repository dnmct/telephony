defmodule Telephony.Core do
  @moduledoc false
  alias __MODULE__.Subscriber
  @subscriber_types [:prepaid, :postpaid]

  def create_subscriber(subscribers, %{subscriber_type: subscriber_type} = payload)
      when subscriber_type in @subscriber_types do
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
