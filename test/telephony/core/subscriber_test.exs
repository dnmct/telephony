defmodule Telephony.Core.SubscriberTest do
  use ExUnit.Case
  alias Telephony.Core.{Postpaid, Prepaid, Subscriber}

  setup do
    postpaid = %Subscriber{
      full_name: "Dan",
      phone_number: "1234567890",
      subscriber_type: %Postpaid{spent: 0}
    }

    prepaid = %Subscriber{
      full_name: "Dan",
      phone_number: "1234567890",
      subscriber_type: %Prepaid{credits: 10, recharges: []}
    }

    %{postpaid: postpaid, prepaid: prepaid}
  end

  test "create a subscriber" do
    payload = %{
      full_name: "Dan",
      phone_number: "1234567890",
      subscriber_type: :prepaid
    }

    result = Subscriber.new(payload)

    expect = %Subscriber{
      full_name: "Dan",
      phone_number: "1234567890",
      subscriber_type: %Prepaid{credits: 0, recharges: []}
    }

    assert expect == result
  end

  test "create a postpaid subscriber" do
    payload = %{
      full_name: "Dan",
      phone_number: "1234567890",
      subscriber_type: :postpaid
    }

    result = Subscriber.new(payload)

    expect = %Subscriber{
      full_name: "Dan",
      phone_number: "1234567890",
      subscriber_type: %Postpaid{spent: 0}
    }

    assert expect == result
  end
end
