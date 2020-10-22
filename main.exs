defmodule Ordered do
  def partition([]), do: [[]]
  def partition(mask) do
    sum = Enum.sum(mask)
    if sum == 0 do
      [Enum.map(mask, fn _ -> [] end)]
    else
      Enum.to_list(1..sum)
      |> permute
      |> Enum.reduce([], fn perm,acc -> 
           {_, part} = Enum.reduce(mask, {perm,[]}, fn num,{pm,a} ->
             {p, rest} = Enum.split(pm, num)
             {rest, [Enum.sort(p) | a]}
           end)
           [Enum.reverse(part) | acc]
         end)
      |> Enum.uniq
    end
  end
 
  defp permute([]), do: [[]]
  defp permute(list), do: for x <- list, y <- permute(list -- [x]), do: [x|y]
end
 
Enum.each([[],[0,0,0],[1,1,1],[2,0,2]], fn test_case ->
  IO.puts "\npartitions #{inspect test_case}:"
  Enum.each(Ordered.partition(test_case), fn part ->
    IO.inspect part
  end)
end)

defmodule Sort do
  def cycleSort(list) do
    tuple = List.to_tuple(list)
    # Loop through the array to find cycles to rotate.
    {data,writes} = Enum.reduce(0 .. tuple_size(tuple)-2, {tuple,0}, fn cycleStart,{data,writes} ->
      item = elem(data, cycleStart)
      pos = find_pos(data, cycleStart, item)
      if pos == cycleStart do
        # If the item is already there, this is not a cycle.
        {data, writes}
      else
        # Otherwise, put the item there or right after any duplicates.
        {data, item} = swap(data, pos, item)
        rotate(data, cycleStart, item, writes+1)
      end
    end)
    {Tuple.to_list(data), writes}
  end
 
  # Rotate the rest of the cycle.
  defp rotate(data, cycleStart, item, writes) do
    pos = find_pos(data, cycleStart, item)
    {data, item} = swap(data, pos, item)
    if pos==cycleStart, do: {data, writes+1},
                      else: rotate(data, cycleStart, item, writes+1)
  end
 
  # Find where to put the item.
  defp find_pos(data, cycleStart, item) do
    cycleStart + Enum.count(cycleStart+1..tuple_size(data)-1, &elem(data, &1) < item)
  end
 
  # Put the item there or right after any duplicates.
  defp swap(data, pos, item) when elem(data, pos)==item, do: swap(data, pos+1, item)
  defp swap(data, pos, item) do
    {put_elem(data, pos, item), elem(data, pos)}
  end
end
 
IO.inspect a = [0, 1, 2, 2, 2, 2, 1, 9, 3.5, 5, 8, 4, 7, 0, 6]
{b, writes} = Sort.cycleSort(a)
IO.puts "writes : #{writes}"
IO.inspect b


defmodule RC do
  def is_perfect(1), do: false
  def is_perfect(n) when n > 1 do
    Enum.sum(factor(n, 2, [1])) == n
  end
 
  defp factor(n, i, factors) when n <  i*i   , do: factors
  defp factor(n, i, factors) when n == i*i   , do: [i | factors]
  defp factor(n, i, factors) when rem(n,i)==0, do: factor(n, i+1, [i, div(n,i) | factors])
  defp factor(n, i, factors)                 , do: factor(n, i+1, factors)
end
 
IO.inspect (for i <- 1..10000, RC.is_perfect(i), do: i)
