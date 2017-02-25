defmodule Double do
  ## GEN SERVER

  use GenServer

  ## CLIENT API

  def start_link, do: GenServer.start_link(__MODULE__, [], name: __MODULE__)
  def call(mod, fun, args), do: GenServer.call(__MODULE__, {:call, mod, fun, args})
  def return(mod, fun, ret), do: GenServer.call(__MODULE__, {:return, mod, fun, ret})
  def called?(mod, fun), do: GenServer.call(__MODULE__, {:called?, mod, fun})
  def called?(mod, fun, args), do: GenServer.call(__MODULE__, {:called?, mod, fun, args})

  ## CALLBACKS
  def init(_) do
    {:ok, {[], %{}}}
  end

  def handle_call({:call, mod, fun, args}, _from, {trail, plan}) do
    {:reply, plan[{mod, fun}], {append(trail, mod, fun, args), plan}}
  end

  def handle_call({:return, mod, fun, ret}, _from, {trail, plan}) do
    {:reply, :ok, {trail, Map.put(plan, {mod, fun}, ret)}}
  end

  def handle_call({:called?, mod, fun}, _from, {trail, plan}) do
    called = case trail[mod] do
      nil -> false
      list -> Enum.find(list, &match?({^fun, _}, &1)) != nil
    end

    {:reply, called, {trail, plan}}
  end

  def handle_call({:called?, mod, fun, args}, _from, {trail, plan}) do
    called = case trail[mod] do
      nil -> false
      list -> Enum.find(list, &match?({^fun, ^args}, &1)) != nil
    end

    {:reply, called, {trail, plan}}
  end

  defp append(trail, mod, fun, args) do
    trail
    |> Keyword.put_new(mod, [])
    |> Keyword.update!(mod, fn xs -> [{fun, args} | xs] end)
  end


  ## MACROS

  defmacro __using__(_) do
    quote do
      @before_compile Double
    end
  end

  defmacro __before_compile__(env) do
    if Mix.env == :test do
      defs =
        env.module
        |> Module.definitions_in(:def)
        |> Enum.map(fn {name, arity} ->
          args = mkargs(env.module, arity)

          quote do
            def unquote(name)(unquote_splicing(args)) do
              Double.call(unquote(env.module), unquote(name), [unquote_splicing(args)])
            end
          end
        end)

      quote do
        defmodule TestDouble do
          unquote(defs)
        end
      end
    end
  end

  defp mkargs(_, 0), do: []
  defp mkargs(mod, n), do: Enum.map(1..n, &Macro.var(:"arg#{&1}", mod))


  ## UTILS

  def get(mod) do
    case Mix.env do
      :test -> Module.concat([mod, TestDouble])
      _     -> mod
    end
  end
end
