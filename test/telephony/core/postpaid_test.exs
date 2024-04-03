defmodule Telephony.Core.PostpaidTest do
  use ExUnit.Case
  alias Telephony.Core.{Call, Postpaid}

  setup do
    %{postpaid: %Postpaid{spent: 0}}
  end

  test "make a call", %{postpaid: postpaid} do
    time_spent = 2
    date = NaiveDateTime.utc_now()
    result = Subscriber.make_call(postpaid, time_spent, date)

    expect = {
      %Postpaid{spent: 2.08},
      %Call{time_spent: time_spent, date: date}
    }

    assert expect == result
  end

  test "throw error when trying to recharge on postpaid", %{postpaid: postpaid} do
    value = 100
    date = NaiveDateTime.utc_now()

    expect = {:error, "Only prepaid subscribers can make recharges"}
    result = Subscriber.make_recharge(postpaid, value, date)

    assert expect == result
  end

  test "print invoice" do
    date = ~D[2024-04-05]
    last_month = ~D[2024-03-15]

    postpaid = %Postpaid{
      spent: 80 * 1.04
    }

    calls = [
      %Call{
        time_spent: 10,
        date: date
      },
      %Call{
        time_spent: 50,
        date: last_month
      },
      %Call{
        time_spent: 30,
        date: last_month
      }
    ]

    assert Subscriber.print_invoice(postpaid, calls, 2024, 3) == %{
             value_spent: 80 * 1.04,
             calls: [
               %{
                 time_spent: 50,
                 value_spent: 50 * 1.04,
                 date: last_month
               },
               %{
                 time_spent: 30,
                 value_spent: 30 * 1.04,
                 date: last_month
               }
             ]
           }
  end
end
