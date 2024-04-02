defmodule Telephony.CoreTest do
  use ExUnit.Case
  alias Telephony.Core
  alias Telephony.Core.{Prepaid, Subscriber}

  setup do
    subscribers = [
      %Subscriber{
        full_name: "Dan",
        phone_number: "1234567890",
        subscriber_type: %Prepaid{credits: 0, recharges: []}
      }
    ]

    payload = %{
      full_name: "Dan",
      phone_number: "1234567890",
      subscriber_type: :prepaid
    }

    %{subscribers: subscribers, payload: payload}
  end

  test "create new subscriber", %{payload: payload} do
    subscribers = []

    result = Core.create_subscriber(subscribers, payload)

    expect = [
      %Subscriber{
        full_name: "Dan",
        phone_number: "1234567890",
        subscriber_type: %Prepaid{credits: 0, recharges: []}
      }
    ]

    assert expect == result
  end

  test "create a new subscriber", %{subscribers: subscribers} do
    payload = %{
      full_name: "Joe",
      phone_number: "0987654321",
      subscriber_type: :prepaid
    }

    result = Core.create_subscriber(subscribers, payload)

    expect = [
      %Subscriber{
        full_name: "Dan",
        phone_number: "1234567890",
        subscriber_type: %Prepaid{credits: 0, recharges: []}
      },
      %Subscriber{
        full_name: "Joe",
        phone_number: "0987654321",
        subscriber_type: %Prepaid{credits: 0, recharges: []}
      }
    ]

    assert expect == result
  end

  test "display error when subscriber already exists", %{
    subscribers: subscribers,
    payload: payload
  } do
    result = Core.create_subscriber(subscribers, payload)
    assert {:error, "Subscriber `1234567890`, already exists"} == result
  end

  test "display error when subscriber_type does not exist", %{
    payload: payload
  } do
    payload = Map.put(payload, :subscriber_type, :asd)
    result = Core.create_subscriber([], payload)
    assert {:error, "Only 'prepaid' or 'postpaid' are accepted"} == result
  end
end
