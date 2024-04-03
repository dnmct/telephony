defmodule Telephony.Core.SubscriberTest do
  use ExUnit.Case
  alias Telephony.Core.{Call, Postpaid, Prepaid, Subscriber}

  setup do
    postpaid = %Subscriber{
      full_name: "Dan",
      phone_number: "1234567890",
      type: %Postpaid{spent: 0}
    }

    prepaid = %Subscriber{
      full_name: "Dan",
      phone_number: "1234567890",
      type: %Prepaid{credits: 10, recharges: []}
    }

    %{postpaid: postpaid, prepaid: prepaid}
  end

  test "create a subscriber" do
    payload = %{
      full_name: "Dan",
      phone_number: "1234567890",
      type: :prepaid
    }

    result = Subscriber.new(payload)

    expect = %Subscriber{
      full_name: "Dan",
      phone_number: "1234567890",
      type: %Prepaid{credits: 0, recharges: []}
    }

    assert expect == result
  end

  test "create a postpaid subscriber" do
    payload = %{
      full_name: "Dan",
      phone_number: "1234567890",
      type: :postpaid
    }

    result = Subscriber.new(payload)

    expect = %Subscriber{
      full_name: "Dan",
      phone_number: "1234567890",
      type: %Postpaid{spent: 0}
    }

    assert expect == result
  end

  test "make a prepaid call" do
    subscriber = %Subscriber{
      full_name: "Dan",
      phone_number: "1234567890",
      type: %Prepaid{credits: 10, recharges: []}
    }

    date = Date.utc_today()

    assert Subscriber.make_call(subscriber, 1, date) == %Subscriber{
             full_name: "Dan",
             phone_number: "1234567890",
             type: %Prepaid{credits: 8.55, recharges: []},
             calls: [%Call{time_spent: 1, date: date}]
           }
  end

  test "make a prepaid call without credits" do
    subscriber = %Subscriber{
      full_name: "Dan",
      phone_number: "1234567890",
      type: %Prepaid{credits: 0, recharges: []}
    }

    date = Date.utc_today()

    assert Subscriber.make_call(subscriber, 1, date) ==
             {:error, "Subscriber does not have enough credits"}
  end

  test "make a postpaid call" do
    subscriber = %Subscriber{
      full_name: "Dan",
      phone_number: "1234567890",
      type: %Postpaid{spent: 0}
    }

    date = Date.utc_today()

    assert Subscriber.make_call(subscriber, 1, date) == %Subscriber{
             full_name: "Dan",
             phone_number: "1234567890",
             type: %Postpaid{spent: 1.04},
             calls: [%Call{time_spent: 1, date: date}]
           }
  end
end
