defmodule HologramSkeleton.HomePage do
  use Hologram.Page

  route "/repro"

  layout HologramSkeleton.DefaultLayout

  # Minimal client-side repro of a JS call-stack overflow in the Hologram interpreter.
  #
  # Each button fires an ACTION, which runs in the compiled client runtime (not the BEAM).
  # The action does ONE Elixir list traversal — `Enum.map/2` over an integer range — and
  # renders its length. On the BEAM this is a tail-recursive loop and is fine at any size.
  # In the client interpreter every Elixir call nests a real JS frame (no TCO), so the
  # per-element recursion of `Enumerable.reduce` overflows V8's stack past a few thousand
  # elements: small n succeeds, large n throws "Maximum call stack size exceeded".

  def init(_params, component, _server) do
    put_state(component, :result, "(not run)")
  end

  def action(:run, %{n: n}, component) do
    list = Enum.map(1..n, fn i -> i end)
    put_state(component, :result, "OK n=#{n} -> length #{length(list)}")
  end

  def template do
    ~HOLO"""
    <div style="font-family:ui-monospace,monospace; padding:24px; font-size:14px;">
      <h1>Hologram interpreter stack-overflow repro</h1>
      <p>Click a button. Each runs <code>Enum.map(1..n, &amp;(&amp;1))</code> client-side.</p>
      <p>
        <button $click={action: :run, params: %{n: 500}}>n = 500</button>
        <button $click={action: :run, params: %{n: 1000}}>n = 1000</button>
        <button $click={action: :run, params: %{n: 2000}}>n = 2000</button>
        <button $click={action: :run, params: %{n: 3000}}>n = 3000</button>
      </p>
      <p id="result">result: {@result}</p>
    </div>
    """
  end
end
