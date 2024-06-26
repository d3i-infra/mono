defmodule Frameworks.Utility.Query do
  require Ecto.Query

  defmacro build(query, key, graph) do
    clauses = compile_clauses(graph, key)

    Enum.reduce(clauses, query, fn clause, query ->
      quote_clause(clause, query)
    end)
  end

  def quote_clause([:join, parent, association], query) do
    quote do
      Ecto.Query.join(
        unquote(query),
        :inner,
        [{unquote(parent), unquote({parent, [], nil})}],
        _ in assoc(unquote({parent, [], nil}), unquote(association)),
        as: unquote(association)
      )
    end
  end

  def quote_clause([:where, parent, expr], query) do
    expr = quote_expr(expr, parent)

    quote do
      Ecto.Query.where(
        unquote(query),
        [{unquote(parent), unquote({parent, [], nil})}],
        unquote(expr)
      )
    end
  end

  def quote_expr({:!=, _, [{property, _, _}, nil]}, parent) do
    parent
    |> quote_property(property)
    |> quote_is_nil()
    |> quote_not()
  end

  def quote_expr({:==, _, [{property, _, _}, nil]}, parent) do
    parent
    |> quote_property(property)
    |> quote_is_nil()
  end

  def quote_expr({operator, _, [{property, _, _}, value]}, parent) do
    {operator, [], [quote_property(parent, property), value]}
  end

  def quote_not(inner_quote) do
    {:not, [], [inner_quote]}
  end

  def quote_is_nil(inner_quote) do
    {:is_nil, [], [inner_quote]}
  end

  def quote_property(parent, property) do
    {{:., [], [{parent, [], nil}, property]}, [no_parens: true], []}
  end

  def compile_clauses([], _parent), do: []

  def compile_clauses([h | t], parent) do
    compile_clauses(h, parent) ++ compile_clauses(t, parent)
  end

  def compile_clauses({assoc, sub_graph}, parent) when is_atom(assoc) and is_list(sub_graph) do
    compile_clauses(assoc, parent) ++ compile_clauses(sub_graph, assoc)
  end

  def compile_clauses(assoc, parent) when is_atom(assoc) do
    [[:join, parent, assoc]]
  end

  def compile_clauses(expr, parent) do
    [[:where, parent, expr]]
  end
end
