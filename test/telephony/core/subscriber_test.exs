defmodule Telephony.Core.SubscriberTest do
  use ExUnit.Case
  alias Telephony.Core.Recharge
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

  test "make a recharge" do
    subscriber = %Subscriber{
      full_name: "Dan",
      phone_number: "1234567890",
      type: %Prepaid{credits: 10, recharges: []}
    }

    date = Date.utc_today()

    assert Subscriber.make_recharge(subscriber, 100, date) == %Subscriber{
             full_name: "Dan",
             phone_number: "1234567890",
             type: %Prepaid{
               credits: 110,
               recharges: [%Recharge{value: 100, date: date}]
             },
             calls: []
           }
  end

  test "make a recharge on postpaid" do
    subscriber = %Subscriber{
      full_name: "Dan",
      phone_number: "1234567890",
      type: %Postpaid{spent: 0}
    }

    date = Date.utc_today()

    assert Subscriber.make_recharge(subscriber, 100, date) ==
             {:error, "Only prepaid subscribers can make recharges"}
  end

  test "print invoice for prepaid" do
    date = ~D[2024-04-05]
    last_month = ~D[2024-03-15]

    subscriber = %Subscriber{
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

    expected_invoice = %{
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

    assert Subscriber.print_invoice(subscriber, 2024, 3) ==
             %{
               subscriber: subscriber,
               invoice: expected_invoice
             }
  end

  test "print invoice for postpaid" do
    date = ~D[2024-04-05]
    last_month = ~D[2024-03-15]

    subscriber = %Subscriber{
      full_name: "Dan",
      phone_number: "1234567890",
      type: %Postpaid{
        spent: 80 * 1.04
      },
      calls: [
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
    }

    expected_invoice = %{
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

    assert Subscriber.print_invoice(subscriber, 2024, 3) == %{
             subscriber: subscriber,
             invoice: expected_invoice
           }
  end
end
