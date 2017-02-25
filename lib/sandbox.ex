defmodule Sandbox.Store do
  use Double

  def users do
    IO.puts "REAL Store.users/0"
    [:real]
  end

  def create(params) do
    IO.puts "REAL Store.create/1"
    {:ok, params}
  end
end

defmodule Sandbox.Controller do
  @store Double.get(Sandbox.Store)

  def index do
    case @store.users() do
      []      -> :zero
      [_one]  -> :one
      _list   -> :many
    end
  end

  def create(kind) do
    @store.create(%{"kind" => kind})
  end


  def devrun do
    index
    create(name: "Alice")
  end
end
