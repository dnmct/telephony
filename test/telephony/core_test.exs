defmodule Telephony.CoreTest do
  use ExUnit.Case
  alias Telephony.Core
  alias Telephony.Core.{Call, Prepaid, Recharge, Subscriber}

  setup do
    last_month = ~D[2024-03-03]

    subscribers = [
      %Subscriber{
        full_name: "Dan",
        phone_number: "1234567890",
        type: %Prepaid{credits: 0, recharges: []}
      },
      %Subscriber{
        full_name: "Franz",
        phone_number: "666666",
        type: %Prepaid{credits: 10, recharges: []},
        calls: [
          %Call{date: last_month, time_spent: 10},
          %Call{date: last_month, time_spent: 20},
          %Call{date: Date.utc_today(), time_spent: 30}
        ]
      }
    ]

    payload = %{
      full_name: "Dan",
      phone_number: "1234567890",
      type: :prepaid
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
        type: %Prepaid{credits: 0, recharges: []}
      }
    ]

    assert expect == result
  end

  test "create a new subscriber", %{subscribers: subscribers} do
    payload = %{
      full_name: "Joe",
      phone_number: "0987654321",
      type: :prepaid
    }

    result = Core.create_subscriber(subscribers, payload)

    expect =
      subscribers ++
        [
          %Subscriber{
            full_name: "Joe",
            phone_number: "0987654321",
            type: %Prepaid{credits: 0, recharges: []}
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

  test "display error when type does not exist", %{
    payload: payload
  } do
    payload = Map.put(payload, :type, :asd)
    result = Core.create_subscriber([], payload)
    assert {:error, "Only 'prepaid' or 'postpaid' are accepted"} == result
  end

  test "search a subscriber", %{subscribers: subscribers} do
    date = Date.utc_today()
    phone_number = "666666"
    result = Core.search_subscriber(subscribers, phone_number)

    expected = %Subscriber{
      full_name: "Franz",
      phone_number: phone_number,
      type: %Prepaid{credits: 10, recharges: []},
      calls: [
        %Call{time_spent: 10, date: ~D[2024-03-03]},
        %Call{time_spent: 20, date: ~D[2024-03-03]},
        %Call{time_spent: 30, date: date}
      ]
    }

    assert result == expected
  end

  test "search a subscriber that does't exist", %{subscribers: subscribers} do
    phone_number = "515151515"
    result = Core.search_subscriber(subscribers, phone_number)

    assert result == nil
  end

  test "make a recharge", %{subscribers: subscribers} do
    phone_number = "666666"
    result = Core.make_recharge(subscribers, phone_number, 100)
    date = Date.utc_today()

    expected =
      {[
         %Subscriber{
           full_name: "Dan",
           phone_number: "1234567890",
           type: %Prepaid{credits: 0, recharges: []},
           calls: []
         },
         %Subscriber{
           full_name: "Franz",
           phone_number: "666666",
           type: %Prepaid{
             credits: 110,
             recharges: [%Recharge{value: 100, date: date}]
           },
           calls: [
             %Call{time_spent: 10, date: ~D[2024-03-03]},
             %Call{time_spent: 20, date: ~D[2024-03-03]},
             %Call{time_spent: 30, date: date}
           ]
         }
       ],
       %Subscriber{
         full_name: "Franz",
         phone_number: "666666",
         type: %Prepaid{
           credits: 110,
           recharges: [%Recharge{value: 100, date: date}]
         },
         calls: [
           %Call{time_spent: 10, date: ~D[2024-03-03]},
           %Call{time_spent: 20, date: ~D[2024-03-03]},
           %Call{time_spent: 30, date: date}
         ]
       }}

    assert result == expected
  end

  test "make a call", %{subscribers: subscribers} do
    date = Date.utc_today()

    expected =
      {[
         %Subscriber{
           full_name: "Dan",
           phone_number: "1234567890",
           type: %Prepaid{credits: 0, recharges: []},
           calls: []
         },
         %Subscriber{
           full_name: "Franz",
           phone_number: "666666",
           type: %Prepaid{credits: 8.55, recharges: []},
           calls: [
             %Call{date: ~D[2024-03-03], time_spent: 10},
             %Call{time_spent: 20, date: ~D[2024-03-03]},
             %Call{time_spent: 30, date: date},
             %Call{time_spent: 1, date: date}
           ]
         }
       ],
       %Subscriber{
         full_name: "Franz",
         phone_number: "666666",
         type: %Prepaid{credits: 8.55, recharges: []},
         calls: [
           %Call{date: ~D[2024-03-03], time_spent: 10},
           %Call{time_spent: 20, date: ~D[2024-03-03]},
           %Call{time_spent: 30, date: date},
           %Call{time_spent: 1, date: date}
         ]
       }}

    result = Core.make_call(subscribers, "666666", 1)

    assert expected == result
  end

  test "print invoice", %{subscribers: subscribers} do
    date = Date.utc_today()

    expected =
      %{
        subscriber: %Subscriber{
          full_name: "Franz",
          phone_number: "666666",
          type: %Prepaid{credits: 10, recharges: []},
          calls: [
            %Call{time_spent: 10, date: ~D[2024-03-03]},
            %Call{time_spent: 20, date: ~D[2024-03-03]},
            %Call{time_spent: 30, date: date}
          ]
        },
        invoice: %{
          credits: 10,
          recharges: [],
          calls: [
            %{date: ~D[2024-03-03], time_spent: 10, value_spent: 14.5},
            %{date: ~D[2024-03-03], time_spent: 20, value_spent: 29.0}
          ]
        }
      }

    result = Core.print_invoice(subscribers, "666666", 2024, 3)
    assert expected == result
  end

  test "print all invoices", %{subscribers: subscribers} do
    date = Date.utc_today()

    expected = [
      %{
        subscriber: %Subscriber{
          full_name: "Dan",
          phone_number: "1234567890",
          type: %Prepaid{credits: 0, recharges: []},
          calls: []
        },
        invoice: %{credits: 0, recharges: [], calls: []}
      },
      %{
        subscriber: %Subscriber{
          full_name: "Franz",
          phone_number: "666666",
          type: %Prepaid{credits: 10, recharges: []},
          calls: [
            %Call{time_spent: 10, date: ~D[2024-03-03]},
            %Call{time_spent: 20, date: ~D[2024-03-03]},
            %Call{time_spent: 30, date: date}
          ]
        },
        invoice: %{
          credits: 10,
          recharges: [],
          calls: [
            %{date: ~D[2024-03-03], time_spent: 10, value_spent: 14.5},
            %{date: ~D[2024-03-03], time_spent: 20, value_spent: 29.0}
          ]
        }
      }
    ]

    result = Core.print_invoices(subscribers, 2024, 3)
    assert expected == result
  end
end
