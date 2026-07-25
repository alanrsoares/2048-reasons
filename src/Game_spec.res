// src/Game.spec.res - ReScript Native Spec Test Harness for Bun Test

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

let gridOfArrays = (matrix: array<array<int>>): grid => {
  matrix->Array.map(r => r->List.fromArray)->List.fromArray
}

let arrayOfGrid = (g: grid): array<array<int>> => {
  g->List.toArray->Array.map(r => r->List.toArray)
}

let getRow = (matrix: array<array<int>>, y: int): array<int> => {
  switch matrix[y] {
  | Some(r) => r
  | None => []
  }
}

let getCell = (matrix: array<array<int>>, y: int, x: int): int => {
  switch matrix[y] {
  | Some(r) =>
    switch r[x] {
    | Some(val) => val
    | None => 0
    }
  | None => 0
  }
}

describe("2048 Game Engine Spec (ReScript Native Test)", () => {
  describe("1. Row Merging Rules (Left & Right)", () => {
    test("Left Move: Basic slide with no merge [0, 2, 0, 0] -> [2, 0, 0, 0]", () => {
      let input = gridOfArrays([[0, 2, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]])
      let res = merge(Left, input)
      let resMatrix = arrayOfGrid(res)

      expect(getRow(resMatrix, 0))->toEqual([2, 0, 0, 0])
    })

    test("Left Move: Single pair merge [2, 2, 0, 0] -> [4, 0, 0, 0]", () => {
      let input = gridOfArrays([[2, 2, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]])
      let res = merge(Left, input)
      let resMatrix = arrayOfGrid(res)

      expect(getRow(resMatrix, 0))->toEqual([4, 0, 0, 0])
    })

    test("Left Move: Triple identical tiles [2, 2, 2, 0] -> [4, 2, 0, 0]", () => {
      let input = gridOfArrays([[2, 2, 2, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]])
      let res = merge(Left, input)
      let resMatrix = arrayOfGrid(res)

      expect(getRow(resMatrix, 0))->toEqual([4, 2, 0, 0])
    })

    test("Left Move: Four identical tiles [2, 2, 2, 2] -> [4, 4, 0, 0]", () => {
      let input = gridOfArrays([[2, 2, 2, 2], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]])
      let res = merge(Left, input)
      let resMatrix = arrayOfGrid(res)

      expect(getRow(resMatrix, 0))->toEqual([4, 4, 0, 0])
    })

    test("Left Move: Two pairs [2, 2, 4, 4] -> [4, 8, 0, 0]", () => {
      let input = gridOfArrays([[2, 2, 4, 4], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]])
      let res = merge(Left, input)
      let resMatrix = arrayOfGrid(res)

      expect(getRow(resMatrix, 0))->toEqual([4, 8, 0, 0])
    })

    test("Left Move: Gaps between identical tiles [2, 0, 2, 0] -> [4, 0, 0, 0]", () => {
      let input = gridOfArrays([[2, 0, 2, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]])
      let res = merge(Left, input)
      let resMatrix = arrayOfGrid(res)

      expect(getRow(resMatrix, 0))->toEqual([4, 0, 0, 0])
    })

    test("Right Move: Single pair merge right [0, 0, 2, 2] -> [0, 0, 0, 4]", () => {
      let input = gridOfArrays([[0, 0, 2, 2], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]])
      let res = merge(Right, input)
      let resMatrix = arrayOfGrid(res)

      expect(getRow(resMatrix, 0))->toEqual([0, 0, 0, 4])
    })

    test("Right Move: Four identical tiles right [2, 2, 2, 2] -> [0, 0, 4, 4]", () => {
      let input = gridOfArrays([[2, 2, 2, 2], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]])
      let res = merge(Right, input)
      let resMatrix = arrayOfGrid(res)

      expect(getRow(resMatrix, 0))->toEqual([0, 0, 4, 4])
    })

    test("Right Move: [0, 0, 4, 4] -> [0, 0, 0, 8]", () => {
      let input = gridOfArrays([[0, 0, 4, 4], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]])
      let res = merge(Right, input)
      let resMatrix = arrayOfGrid(res)

      expect(getRow(resMatrix, 0))->toEqual([0, 0, 0, 8])
    })
  })

  describe("2. Column Merging Rules (Up & Down)", () => {
    test("Up Move: merges column [2, 2, 2, 2] into [4, 4, 0, 0]", () => {
      let input = gridOfArrays([[2, 0, 0, 0], [2, 0, 0, 0], [2, 0, 0, 0], [2, 0, 0, 0]])
      let res = merge(Up, input)
      let resMatrix = arrayOfGrid(res)

      expect(getCell(resMatrix, 0, 0))->toBe(4)
      expect(getCell(resMatrix, 1, 0))->toBe(4)
      expect(getCell(resMatrix, 2, 0))->toBe(0)
      expect(getCell(resMatrix, 3, 0))->toBe(0)
    })

    test("Down Move: merges column [2, 2, 2, 2] into [0, 0, 4, 4]", () => {
      let input = gridOfArrays([[2, 0, 0, 0], [2, 0, 0, 0], [2, 0, 0, 0], [2, 0, 0, 0]])
      let res = merge(Down, input)
      let resMatrix = arrayOfGrid(res)

      expect(getCell(resMatrix, 0, 0))->toBe(0)
      expect(getCell(resMatrix, 1, 0))->toBe(0)
      expect(getCell(resMatrix, 2, 0))->toBe(4)
      expect(getCell(resMatrix, 3, 0))->toBe(4)
    })
  })

  describe("3. Engine Utilities & AI Solver", () => {
    test("detects full grid with no moves", () => {
      let fullGrid = gridOfArrays([[2, 4, 2, 4], [4, 2, 4, 2], [2, 4, 2, 4], [4, 2, 4, 2]])

      expect(isMergeable(fullGrid))->toBe(false)
      expect(bestMove(fullGrid))->toEqual(None)
    })

    test("correctly calculates score and max tile", () => {
      let grid = gridOfArrays([
        [2, 4, 8, 16],
        [32, 64, 128, 256],
        [512, 1024, 2048, 0],
        [0, 0, 0, 0],
      ])

      expect(getMaxTile(grid))->toBe(2048)
      expect(getScore(grid))->toBe(4094)
    })
  })
})
