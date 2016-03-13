defmodule TrieNode do

  require IEx

  def new do
    {false, %{}}
  end

  def insert({end_word, children}, [letter | rest]) do

    new_map = Map.update(children, letter, insert(new, rest), fn child ->
      insert(child, rest)
    end)

    {end_word, new_map}
  end

  def insert({_end_word, children}, []) do
    {true, children}
  end

  def contains?({_end_word, children}, [letter | rest]) do
    t1 = :os.system_time(:micro_seconds)

    result = case Map.get(children, letter) do
      nil -> false
      node -> contains?(node, rest)
    end

    t2 = :os.system_time(:micro_seconds)

    IO.puts "#{(t2 - t1) / 1000} ms"

    result
  end

  def contains?({end_word, _children}, []) do
    end_word
  end

  def search({_end_word, children}, word, max_cost) do
    t1 = :os.system_time(:micro_seconds)

    initial_row = Enum.to_list 0..length(word)

    result = Enum.reduce(Map.keys(children), [], fn (letter, acc) ->
      child = Map.get(children, letter)
      acc ++ search_recursive(child, letter, word, [letter], initial_row, max_cost)
    end)

    t2 = :os.system_time(:micro_seconds)

    IO.puts "#{(t2 - t1) / 1000} ms"

    result
  end

  def search_recursive({end_word, children}, letter, word, built_word, previous_row, max_cost) do

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
      results = [{built_word, Enum.at(current_row, -1)}]
    end

    if Enum.min(current_row) <= max_cost do
      Enum.reduce(Map.keys(children), results, fn (letter, acc) ->
        child = Map.get(children, letter)
        acc ++ search_recursive(child, letter, word, built_word ++ [letter], current_row, max_cost)
      end)
    else
      results
    end

  end

end
 
# # This recursive helper is used by the search function above. It assumes that
# # the previousRow has been filled in already.
# def searchRecursive( node, letter, word, previousRow, results, maxCost ):
# 
#     columns = len( word ) + 1
#     currentRow = [ previousRow[0] + 1 ]
# 
#     # Build one row for the letter, with a column for each letter in the target
#     # word, plus one for the empty string at column 0
#     for column in xrange( 1, columns ):
# 
#         insertCost = currentRow[column - 1] + 1
#         deleteCost = previousRow[column] + 1
# 
#         if word[column - 1] != letter:
#             replaceCost = previousRow[ column - 1 ] + 1
#         else:
#             replaceCost = previousRow[ column - 1 ]
# 
#         currentRow.append( min( insertCost, deleteCost, replaceCost ) )
# 
#     # if the last entry in the row indicates the optimal cost is less than the
#     # maximum cost, and there is a word in this trie node, then add it.
#     if currentRow[-1] <= maxCost and node.word != None:
#         results.append( (node.word, currentRow[-1] ) )
# 
#     # if any entries in the row are less than the maximum cost, then 
#     # recursively search each branch of the trie
#     if min( currentRow ) <= maxCost:
#         for letter in node.children:
#             searchRecursive( node.children[letter], letter, word, currentRow, 
#                 results, maxCost )
# 
# start = time.time()
# results = search( TARGET, MAX_COST )
# end = time.time()
# 
# for result in results: print result        
# 
# print "Search took %g s" % (end - start)

# # The search function returns a list of all words that are less than the given
# # maximum distance from the target word
# def search( word, maxCost ):
# 
#     # build first row
#     currentRow = range( len(word) + 1 )
# 
#     results = []
# 
#     # recursively search each branch of the trie
#     for letter in trie.children:
#         searchRecursive( trie.children[letter], letter, word, currentRow, 
#             results, maxCost )
# 
#     return results
#
