defmodule Day17runner do
  def example do
    # Example maze
    maze = """
    ###############
    #.......#....E#
    #.#.###.#.###.#
    #.....#.#...#.#
    #.###.#####.#.#
    #.#.#.......#.#
    #.#.#####.###.#
    #...........#.#
    ###.#.#####.#.#
    #...#.....#.#.#
    #.#.#.###.#.#.#
    #.....#...#.#.#
    #.###.#.#.#.#.#
    #S..#.....#...#
    ###############
    """

    # Solve the maze
    Day17.final_paths_to_coordinates(maze)
  end

  def solve,
    do:
      File.read!("/Users/niki/aoc2024/input/day17.txt")
      |> Day17.final_paths_to_coordinates()
end
