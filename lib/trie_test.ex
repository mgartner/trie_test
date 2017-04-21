defmodule TrieTest do


end

require IEx

stream = File.stream!("/usr/share/dict/words")

trie = Enum.reduce(stream, TrieNode.new, fn (line, node) ->
  word = line |> String.strip |> String.downcase
  TrieNode.insert(node, :binary.bin_to_list(word))
end)

# trie = TrieNode.new
# 
# trie = TrieNode.insert(trie, 'hello')
# trie = TrieNode.insert(trie, 'hell')
# trie = TrieNode.insert(trie, 'hallo')
# trie = TrieNode.insert(trie, 'helicopter')

IO.inspect TrieNode.contains?(trie, 'hello')
IO.inspect TrieNode.contains?(trie, 'asdf')
IO.inspect TrieNode.contains?(trie, 'hell')
IO.inspect TrieNode.contains?(trie, 'hello')

IO.inspect TrieNode.search(trie, 'hello', 1)


# :eflame.apply(&Excaliper.TestBenchmark.run_profile/0, [])
#:eflame.apply(&TrieNode.search/3, [trie, 'hello', 2])

IEx.pry
