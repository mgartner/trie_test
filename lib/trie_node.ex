defmodule TrieNode do

  require IEx

  def new do
    {%{}, nil}
  end

  def insert({children, end_word}, [letter | rest], word \\ nil) do
    word = word || [letter | rest]

    new_map = Map.update(children, letter, insert(new, rest, word), fn child ->
      insert(child, rest, word)
    end)

    {new_map, end_word}
  end

  def insert({children, _end_word}, [], word) do
    {children, word}
  end

  def contains?({children, _end_word}, [letter | rest]) do
    t1 = :os.system_time(:micro_seconds)

    result = case Map.get(children, letter) do
      nil -> false
      node -> contains?(node, rest)
    end

    t2 = :os.system_time(:micro_seconds)

    IO.puts "#{(t2 - t1) / 1000} ms"

    result
  end

  def contains?({_children, end_word}, []) do
    end_word == nil
  end

  def search({children, _end_word}, word, max_cost) do
    t1 = :os.system_time(:micro_seconds)

    initial_row = Enum.to_list 0..length(word)

    result = Enum.reduce(Map.keys(children), [], fn (letter, acc) ->
      child = Map.get(children, letter)
      acc ++ search_recursive(child, letter, word, initial_row, max_cost)
    end)

    t2 = :os.system_time(:micro_seconds)

    IO.puts "#{(t2 - t1) / 1000} ms"

    result
  end

  def search_recursive({children, end_word}, letter, word, previous_row, max_cost) do

    current_row = [hd(previous_row) + 1]

    current_row = Enum.reduce(1..length(word), current_row, fn (column, row) ->
      insert_cost = Enum.at(row, column - 1) + 1
      delete_cost = Enum.at(previous_row, column) + 1

      replace_cost = case Enum.at(word, column - 1) do
        ^letter -> Enum.at(previous_row, column - 1)
        _ -> Enum.at(previous_row, column - 1) + 1
      end

      cost = Enum.min([insert_cost, delete_cost, replace_cost])

      row ++ [cost]
    end)

    results = []

    if Enum.at(current_row, -1) <= max_cost && end_word do
      results = [{end_word, Enum.at(current_row, -1)}]
    end

    if Enum.min(current_row) <= max_cost do
      Enum.reduce(Map.keys(children), results, fn (letter, acc) ->
        child = Map.get(children, letter)
        acc ++ search_recursive(child, letter, word, current_row, max_cost)
      end)
    else
      results
    end
  end

  def search_binary({children, _end_word}, word, max_cost, prefix \\ nil) do
    t1 = :os.system_time(:micro_seconds)

    initial_row = 0..length(word) |> Enum.to_list |> :binary.list_to_bin


    result = Enum.reduce(Map.keys(children), [], fn (letter, acc) ->
      child = Map.get(children, letter)
      if (prefix && prefix == letter) || !prefix do
        acc ++ search_binary_recursive(child, letter, word, initial_row, max_cost)
      else
        acc
      end
    end)

    t2 = :os.system_time(:micro_seconds)

    IO.puts "#{(t2 - t1) / 1000} ms"

    result
  end

  def search_binary_recursive({children, end_word}, letter, word, previous_row, max_cost) do

    current_row = <<:binary.at(previous_row, 0) + 1>>

    current_row = Enum.reduce(1..length(word), current_row, fn (column, row) ->
      insert_cost = :binary.at(row, column - 1) + 1
      delete_cost = :binary.at(previous_row, column) + 1

      replace_cost = case Enum.at(word, column - 1) do
        ^letter -> :binary.at(previous_row, column - 1)
        _ -> :binary.at(previous_row, column - 1) + 1
      end

      cost = Enum.min([insert_cost, delete_cost, replace_cost])

      row <> <<cost>>
    end)

    results = []

    last = :binary.last(current_row)

    if last <= max_cost && end_word do
      results = [{end_word, last}]
    end

    min_cost = current_row |> :binary.bin_to_list |> Enum.min

    if min_cost <= max_cost do
      Enum.reduce(Map.keys(children), results, fn (letter, acc) ->
        child = Map.get(children, letter)
        acc ++ search_binary_recursive(child, letter, word, current_row, max_cost)
      end)
    else
      results
    end
  end



end
