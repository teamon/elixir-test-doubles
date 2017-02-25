defmodule Sandbox.ControllerTest do
  use ExUnit.Case

  alias Sandbox.Controller

  ## TEST QUERIES

  test "index when zero" do
    Double.return(Sandbox.Store, :users, [])

    assert Controller.index == :zero
  end

  test "index when one" do
    Double.return(Sandbox.Store, :users, [:alice])

    assert Controller.index == :one
  end

  test "index when many" do
    Double.return(Sandbox.Store, :users, [:alice, :bob, :eve, :dave])

    assert Controller.index == :many
  end


  ## TEST COMMANDS

  test "create good" do
    Controller.create(:good)

    assert Double.called?(Sandbox.Store, :create)
  end

  test "create bad" do
    Controller.create(:bad)

    assert Double.called?(Sandbox.Store, :create, [%{"kind" => :bad}])
  end
end
