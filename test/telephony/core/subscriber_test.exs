defmodule Telephony.Core.SubscriberTest do
  use ExUnit.Case
  alias Telephony.Core.Recharge
  alias Telephony.Core.{Call, Postpaid, Prepaid, Recharge, Subscriber}

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

  test "make a postpaid call", %{postpaid: postpaid} do
    time_spent = 2
    date = NaiveDateTime.utc_now()

    expect = %Subscriber{
      full_name: "Dan",
      phone_number: "1234567890",
      subscriber_type: %Postpaid{spent: 2.08},
      calls: [
        %Call{
          time_spent: time_spent,
          date: date
        }
      ]
    }

    result = Subscriber.make_call(postpaid, time_spent, date)

    assert expect == result
  end

  test "make a prepaid call", %{prepaid: prepaid} do
    time_spent = 2
    date = NaiveDateTime.utc_now()

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

    result = Subscriber.make_call(prepaid, time_spent, date)

    assert expect == result
  end

  test "make a recharge", %{prepaid: prepaid} do
    value = 100
    date = NaiveDateTime.utc_now()

    expect = %Subscriber{
      full_name: "Dan",
      phone_number: "1234567890",
      subscriber_type: %Prepaid{
        credits: 110,
        recharges: [
          %Recharge{value: 100, date: date}
        ]
      },
      calls: []
    }

    result = Subscriber.make_recharge(prepaid, value, date)

    assert expect == result
  end

  test "throw error when trying to recharge on postpaid", %{postpaid: postpaid} do
    value = 100
    date = NaiveDateTime.utc_now()

    expect = {:error, "Only prepaid subscribers can make recharges"}
    result = Subscriber.make_recharge(postpaid, value, date)

    assert expect == result
  end
end
