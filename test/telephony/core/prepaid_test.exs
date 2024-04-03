defmodule Telephony.Core.PrepaidTest do
  use ExUnit.Case
  alias Telephony.Core.{Call, Prepaid, Recharge}

  setup do
    with_credits = %Prepaid{credits: 10, recharges: []}

    without_credits = %Prepaid{credits: 0, recharges: []}

    %{with_credits: with_credits, without_credits: without_credits}
  end

  test "make a call", %{with_credits: with_credits} do
    time_spent = 2
    date = NaiveDateTime.utc_now()
    result = Subscriber.make_call(with_credits, time_spent, date)

    expect = {
      %Prepaid{credits: 7.1, recharges: []},
      %Call{
        time_spent: time_spent,
        date: date
      }
    }

    assert expect == result
  end

  test "try to make a call", %{without_credits: without_credits} do
    time_spent = 2
    date = NaiveDateTime.utc_now()
    result = Subscriber.make_call(without_credits, time_spent, date)

    expect = {:error, "Subscriber does not have enough credits"}

    assert expect == result
  end

  test "make a recharge", %{with_credits: with_credits} do
    value = 100
    date = NaiveDateTime.utc_now()

    result = Subscriber.make_recharge(with_credits, value, date)

    expect = %Prepaid{
      credits: 110,
      recharges: [
        %Recharge{
          value: value,
          date: date
        }
      ]
    }

    assert expect == result
  end

  test "print invoice" do
    date = ~D[2024-04-05]
    last_month = ~D[2024-03-15]

    subscriber = %Telephony.Core.Subscriber{
      full_name: "Dan",
      phone_number: "1234567890",
      type: %Prepaid{
        credits: 253.6,
        recharges: [
          %Recharge{value: 100, date: date},
          %Recharge{value: 100, date: last_month},
          %Recharge{value: 100, date: last_month}
        ]
      },
      calls: [
        %Call{
          time_spent: 2,
          date: date
        },
        %Call{
          time_spent: 10,
          date: last_month
        },
        %Call{
          time_spent: 20,
          date: last_month
        }
      ]
    }

    type = subscriber.type
    calls = subscriber.calls

    assert Subscriber.print_invoice(type, calls, 2024, 3) == %{
             calls: [
               %{
                 time_spent: 10,
                 value_spent: 14.5,
                 date: last_month
               },
               %{
                 time_spent: 20,
                 value_spent: 29.0,
                 date: last_month
               }
             ],
             recharges: [
               %Recharge{value: 100, date: last_month},
               %Recharge{value: 100, date: last_month}
             ],
             credits: 253.6
           }
  end
end
