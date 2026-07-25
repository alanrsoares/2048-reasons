// src/Game_spec.res - ReScript Native Spec Test Harness for Persistent Tile Engine

open Game

module BunTest = {
  @module("bun:test") external describe: (string, unit => unit) => unit = "describe"
  @module("bun:test") external test: (string, unit => unit) => unit = "test"

  module Expect = {
    type t
    @module("bun:test") external expect: 'a => t = "expect"
    @send external toEqual: (t, 'a) => unit = "toEqual"
    @send external toBe: (t, 'a) => unit = "toBe"
  }
}

open BunTest
open BunTest.Expect

let gridOfArrays = (matrix: array<array<int>>): array<tile> => {
  let tiles = []
  let id = ref(1)
  matrix->Array.forEachWithIndex((row, r) => {
    row->Array.forEachWithIndex((val, c) => {
      if val > 0 {
        let _ = tiles->Array.push({
          id: id.contents,
          val,
          row: r,
          col: c,
          isNew: false,
          isMerged: false,
        })
        id := id.contents + 1
      }
    })
  })
  tiles
}

describe("2048 Game Engine Spec (ReScript Native Test)", () => {
  describe("1. Row Merging Rules (Left & Right)", () => {
    test(
      "Left Move: Basic slide with no merge [0, 2, 0, 0] -> [2, 0, 0, 0]",
      () => {
        let input = gridOfArrays([[0, 2, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]])
        let res = moveGrid(input, Left, 100)
        let resMatrix = tilesToMatrix(res.tiles)

        expect(resMatrix[0])->toEqual(Some([2, 0, 0, 0]))
      },
    )

    test(
      "Left Move: Single pair merge [2, 2, 0, 0] -> [4, 0, 0, 0]",
      () => {
        let input = gridOfArrays([[2, 2, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]])
        let res = moveGrid(input, Left, 100)
        let resMatrix = tilesToMatrix(res.tiles)

        expect(resMatrix[0])->toEqual(Some([4, 0, 0, 0]))
      },
    )

    test(
      "Left Move: Triple identical tiles [2, 2, 2, 0] -> [4, 2, 0, 0]",
      () => {
        let input = gridOfArrays([[2, 2, 2, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]])
        let res = moveGrid(input, Left, 100)
        let resMatrix = tilesToMatrix(res.tiles)

        expect(resMatrix[0])->toEqual(Some([4, 2, 0, 0]))
      },
    )

    test(
      "Left Move: Four identical tiles [2, 2, 2, 2] -> [4, 4, 0, 0]",
      () => {
        let input = gridOfArrays([[2, 2, 2, 2], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]])
        let res = moveGrid(input, Left, 100)
        let resMatrix = tilesToMatrix(res.tiles)

        expect(resMatrix[0])->toEqual(Some([4, 4, 0, 0]))
      },
    )

    test(
      "Left Move: Two pairs [2, 2, 4, 4] -> [4, 8, 0, 0]",
      () => {
        let input = gridOfArrays([[2, 2, 4, 4], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]])
        let res = moveGrid(input, Left, 100)
        let resMatrix = tilesToMatrix(res.tiles)

        expect(resMatrix[0])->toEqual(Some([4, 8, 0, 0]))
      },
    )

    test(
      "Left Move: Gaps between identical tiles [2, 0, 2, 0] -> [4, 0, 0, 0]",
      () => {
        let input = gridOfArrays([[2, 0, 2, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]])
        let res = moveGrid(input, Left, 100)
        let resMatrix = tilesToMatrix(res.tiles)

        expect(resMatrix[0])->toEqual(Some([4, 0, 0, 0]))
      },
    )

    test(
      "Right Move: Single pair merge right [0, 0, 2, 2] -> [0, 0, 0, 4]",
      () => {
        let input = gridOfArrays([[0, 0, 2, 2], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]])
        let res = moveGrid(input, Right, 100)
        let resMatrix = tilesToMatrix(res.tiles)

        expect(resMatrix[0])->toEqual(Some([0, 0, 0, 4]))
      },
    )

    test(
      "Right Move: Four identical tiles right [2, 2, 2, 2] -> [0, 0, 4, 4]",
      () => {
        let input = gridOfArrays([[2, 2, 2, 2], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]])
        let res = moveGrid(input, Right, 100)
        let resMatrix = tilesToMatrix(res.tiles)

        expect(resMatrix[0])->toEqual(Some([0, 0, 4, 4]))
      },
    )

    test(
      "Right Move: [0, 0, 4, 4] -> [0, 0, 0, 8]",
      () => {
        let input = gridOfArrays([[0, 0, 4, 4], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]])
        let res = moveGrid(input, Right, 100)
        let resMatrix = tilesToMatrix(res.tiles)

        expect(resMatrix[0])->toEqual(Some([0, 0, 0, 8]))
      },
    )
  })

  describe("2. Column Merging Rules (Up & Down)", () => {
    test(
      "Up Move: merges column [2, 2, 2, 2] into [4, 4, 0, 0]",
      () => {
        let input = gridOfArrays([[2, 0, 0, 0], [2, 0, 0, 0], [2, 0, 0, 0], [2, 0, 0, 0]])
        let res = moveGrid(input, Up, 100)
        let resMatrix = tilesToMatrix(res.tiles)

        expect(resMatrix[0])->toEqual(Some([4, 0, 0, 0]))
        expect(resMatrix[1])->toEqual(Some([4, 0, 0, 0]))
        expect(resMatrix[2])->toEqual(Some([0, 0, 0, 0]))
        expect(resMatrix[3])->toEqual(Some([0, 0, 0, 0]))
      },
    )

    test(
      "Down Move: merges column [2, 2, 2, 2] into [0, 0, 4, 4]",
      () => {
        let input = gridOfArrays([[2, 0, 0, 0], [2, 0, 0, 0], [2, 0, 0, 0], [2, 0, 0, 0]])
        let res = moveGrid(input, Down, 100)
        let resMatrix = tilesToMatrix(res.tiles)

        expect(resMatrix[0])->toEqual(Some([0, 0, 0, 0]))
        expect(resMatrix[1])->toEqual(Some([0, 0, 0, 0]))
        expect(resMatrix[2])->toEqual(Some([4, 0, 0, 0]))
        expect(resMatrix[3])->toEqual(Some([4, 0, 0, 0]))
      },
    )
  })

  describe("3. Engine Utilities & AI Solver", () => {
    test(
      "detects full grid with no moves",
      () => {
        let fullGrid = gridOfArrays([[2, 4, 2, 4], [4, 2, 4, 2], [2, 4, 2, 4], [4, 2, 4, 2]])

        expect(isMergeable(fullGrid))->toBe(false)
        expect(bestMove(fullGrid))->toEqual(None)
      },
    )

    test(
      "correctly calculates score and max tile",
      () => {
        let tiles = gridOfArrays([
          [2, 4, 8, 16],
          [32, 64, 128, 256],
          [512, 1024, 2048, 0],
          [0, 0, 0, 0],
        ])

        expect(getMaxTile(tiles))->toBe(2048)
        expect(getScore(tiles))->toBe(4094)
      },
    )
  })
})
