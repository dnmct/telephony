defmodule Telephony.ServerTest do
  use ExUnit.Case
  alias Telephony.Server
  alias Telephony.Core.{Prepaid, Recharge, Subscriber}

  setup do
    {:ok, pid} = Server.start_link(:test)
    payload = %{full_name: "Dan", phone_number: "123", type: :prepaid}
    %{pid: pid, process_name: :test, payload: payload}
  end

  test "check telephony subscribers state", %{pid: pid} do
    assert [] = :sys.get_state(pid)
  end

  test "create a subscriber", %{process_name: process_name, payload: payload} do
    prev_state = :sys.get_state(process_name)
    assert [] == prev_state

    result = GenServer.call(process_name, {:create_subscriber, payload})

    refute prev_state == result
  end

  test "throw error when subscriber already exists", %{
    process_name: process_name,
    payload: payload
  } do
    GenServer.call(process_name, {:create_subscriber, payload})
    result = GenServer.call(process_name, {:create_subscriber, payload})

    assert {:error, "Subscriber `123`, already exists"} == result
  end

  test "search subscriber", %{process_name: process_name, payload: payload} do
    GenServer.call(process_name, {:create_subscriber, payload})
    result = GenServer.call(process_name, {:search_subscriber, payload.phone_number})

    assert result.full_name == payload.full_name
  end

  test "make reacharge", %{process_name: process_name, payload: payload} do
    date = Date.utc_today()
    GenServer.call(process_name, {:create_subscriber, payload})

    state = :sys.get_state(process_name)
    subscriber_state = hd(state)
    assert subscriber_state.type.recharges == []
    :ok = GenServer.cast(process_name, {:make_recharge, payload.phone_number, 100})

    state = :sys.get_state(process_name)
    subscriber_state = hd(state)
    refute subscriber_state.type.recharges == []
  end
end
