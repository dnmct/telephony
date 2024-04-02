defmodule Telephony.Core.PrepaidTest do
  use ExUnit.Case
  alias Telephony.Core.{Call, Prepaid, Recharge, Subscriber}

  setup do
    subscriber = %Subscriber{
      full_name: "Dan",
      phone_number: "1234567890",
      subscriber_type: %Prepaid{credits: 10, recharges: []}
    }

    subscriber_without_credits = %Subscriber{
      full_name: "Dan",
      phone_number: "1234567890",
      subscriber_type: %Prepaid{credits: 0, recharges: []}
    }

    %{subscriber: subscriber, subscriber_without_credits: subscriber_without_credits}
  end

  test "make a call", %{subscriber: subscriber} do
    time_spent = 2
    date = NaiveDateTime.utc_now()
    result = Prepaid.make_call(subscriber, time_spent, date)

    expect = %Subscriber{
      full_name: "Dan",
      phone_number: "1234567890",
      subscriber_type: %Prepaid{credits: 7.1, recharges: []},
      calls: [
        %Call{
          time_spent: time_spent,
          date: date
        }
      ]
    }

    assert expect == result
  end

  test "try to make a call", %{subscriber_without_credits: subscriber_without_credits} do
    time_spent = 2
    date = NaiveDateTime.utc_now()
    result = Prepaid.make_call(subscriber_without_credits, time_spent, date)

    expect = {:error, "Subscriber does not have enough credits"}

    assert expect == result
  end

  test "make a recharge", %{subscriber: subscriber} do
    value = 100
    date = NaiveDateTime.utc_now()

    result = Prepaid.make_recharge(subscriber, value, date)

    expect = %Subscriber{
      full_name: "Dan",
      phone_number: "1234567890",
      subscriber_type: %Prepaid{
        credits: 110,
        recharges: [
          %Recharge{
            value: value,
            date: date
          }
        ]
      },
      calls: []
    }

    assert expect == result
  end
end
