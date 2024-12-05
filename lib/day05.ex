defmodule Day05 do
  @test_data "/Users/niki/aoc2024/input/mini_day05.txt"
  @data "/Users/niki/aoc2024/input/day05.txt"

  def parse_file(file_path) do
    {:ok, content} = File.read(file_path)

    [first_part, second_part] =
      content
      |> String.split(~r/\n\s*\n/, parts: 2, trim: true)

    tuples =
      first_part
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        line
        |> String.split("|", trim: true)
        |> then(fn [a, b] -> {String.to_integer(a), String.to_integer(b)} end)
      end)

    lists =
      second_part
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        line
        |> String.split(",", trim: true)
        |> Enum.map(&String.to_integer/1)
      end)

    %{rules: tuples, updates: lists}
  end

  def test1 do
    data = parse_file(@test_data)
    # IO.inspect(data)
    solve1(data)
  end

  def do_it do
    data = parse_file(@data)
    # IO.inspect(data)
    solve1(data)
  end

  def test2 do
    data = parse_file(@test_data)
    # IO.inspect(data)
    solve2(data)
  end

  def do_it2 do
    data = parse_file(@data)
    # IO.inspect(data)
    solve2(data)
  end

  def solve2(%{rules: rules, updates: updates}) do
    incorrect = Enum.filter(updates, &(verify_update(rules, &1) == nil))

    Enum.map(incorrect, &fix_incorrect(rules, &1))
    |> IO.inspect(charlists: :as_lists, label: "solve2")
    |> Enum.map(&get_middle/1)
    |> IO.inspect(charlists: :as_list)
    |> Enum.sum()
  end

  def fix_incorrect(rules, pages) do
    filtered_rules = Enum.filter(rules, fn {first, _second} -> first in pages end)
    # IO.inspect(filtered_rules, charlists: :as_list, label: "TO_FIX_RULES")
    # IO.inspect(pages, charlists: :as_list, label: "TO_FIX")
    fix_incorrect(filtered_rules, pages, [])
  end

  def solve2t(%{rules: rules, updates: updates}) do
    incorrect = Enum.filter(updates, &(verify_update(rules, &1) == nil))
    pages = List.first(incorrect)
    filtered_rules = Enum.filter(rules, fn {first, _second} -> first in pages end)
    _fixed = fix_incorrect(filtered_rules, pages, [])
    # IO.inspect(fixed, charlists: :as_list, label: "Solution")
  end

  def fix_incorrect(_, [], fixed_pages) do
    # IO.puts("FINAL #{inspect(fixed_pages)}")
    fixed = fixed_pages
    IO.inspect(fixed, charlists: :as_lists, label: "FIXED: ")
    fixed
  end

  def fix_incorrect(rules, pages, already_printed) do
    # IO.inspect(["fix_incorrect", pages, already_printed], charlists: :as_lists)

    {left, [page | right]} = Enum.split_while(pages, &(not page_ok(rules, &1, already_printed)))
    pages = left ++ right
    # index = Enum.find_index(pages, fn p -> page_ok(rules, p, already_printed) end)
    # page = Enum.at(pages, index)
    # pages = List.delete(pages, page)
    # IO.inspect([page, pages], charlists: :as_lists)
    fix_incorrect(rules, pages, already_printed ++ [page])
  end

  def solve1(%{rules: rules, updates: updates}) do
    Enum.filter(updates, &verify_update(rules, &1))
    |> IO.inspect()
    |> Enum.map(&get_middle(&1))
    |> Enum.sum()
  end

  def get_middle(list) do
    middle_index = div(length(list), 2)
    Enum.at(list, middle_index)
  end

  def verify_update(rules, pages) do
    filtered_rules = Enum.filter(rules, fn {first, _second} -> first in pages end)
    # IO.inspect(["Checking....", filtered_rules, pages], charlists: :as_lists)
    check_update(filtered_rules, pages, MapSet.new())
  end

  def check_update(rules, [page | rest], already_printed_pages) do
    # IO.puts("check_update:  Page #{page}, already printed #{inspect(already_printed_pages)}")

    if page_ok(rules, page, already_printed_pages) do
      already_printed_pages = MapSet.put(already_printed_pages, page)
      check_update(rules, rest, already_printed_pages)
    else
      nil
    end
  end

  def check_update(_, [], _), do: true

  def page_ok(rules, page, already_printed_pages) do
    # IO.inspect(["pair_ok data", page, already_printed_pages], charlists: :as_lists)

    before_pages =
      Enum.filter(rules, fn {_a, b} -> b == page end)
      |> Enum.map(&elem(&1, 0))

    # IO.inspect(["pair_ok data", before_pages, page, already_printed_pages], charlists: :as_lists)
    Enum.all?(before_pages, &Enum.member?(already_printed_pages, &1))
  end
end
