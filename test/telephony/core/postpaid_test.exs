defmodule Telephony.Core.PostpaidTest do
  use ExUnit.Case
  alias Telephony.Core.{Call, Postpaid, Subscriber}

  setup do
    subscriber = %Subscriber{
      full_name: "Dan",
      phone_number: "1234567890",
      subscriber_type: %Postpaid{spent: 0},
      calls: []
    }

    %{subscriber: subscriber}
  end

  test "make a call", %{subscriber: subscriber} do
    time_spent = 2
    date = NaiveDateTime.utc_now()
    result = Postpaid.make_call(subscriber, time_spent, date)

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

    assert expect == result
  end
end
