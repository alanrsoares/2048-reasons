import { expect, test, describe } from "bun:test";
// @ts-ignore
import * as Game from "../src/Game.res.js";

// ReScript v12 list representation helper: nil is 0, cons is { hd, tl }
function toList(arr: any[]): any {
  let result = 0;
  for (let i = arr.length - 1; i >= 0; i--) {
    result = { hd: arr[i], tl: result };
  }
  return result;
}

function toGrid(matrix: number[][]): any {
  return toList(matrix.map(toList));
}

function fromList(list: any): any[] {
  const result: any[] = [];
  let curr = list;
  while (curr !== 0 && curr !== undefined && curr !== null) {
    result.push(curr.hd);
    curr = curr.tl;
  }
  return result;
}

function fromGrid(grid: any): number[][] {
  return fromList(grid).map(fromList);
}

describe("2048 Game Engine Spec (Original 2048-Reasons Standard)", () => {
  describe("1. Row Merging Rules (Left & Right)", () => {
    test("Left Move: Basic slide with no merge [0, 2, 0, 0] -> [2, 0, 0, 0]", () => {
      const input = toGrid([
        [0, 2, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      const res = Game.merge("Left", input);
      const resMatrix = fromGrid(res);

      expect(resMatrix[0]).toEqual([2, 0, 0, 0]);
    });

    test("Left Move: Single pair merge [2, 2, 0, 0] -> [4, 0, 0, 0]", () => {
      const input = toGrid([
        [2, 2, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      const res = Game.merge("Left", input);
      const resMatrix = fromGrid(res);

      expect(resMatrix[0]).toEqual([4, 0, 0, 0]);
    });

    test("Left Move: Triple identical tiles [2, 2, 2, 0] -> [4, 2, 0, 0]", () => {
      const input = toGrid([
        [2, 2, 2, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      const res = Game.merge("Left", input);
      const resMatrix = fromGrid(res);

      expect(resMatrix[0]).toEqual([4, 2, 0, 0]);
    });

    test("Left Move: Four identical tiles [2, 2, 2, 2] -> [4, 4, 0, 0]", () => {
      const input = toGrid([
        [2, 2, 2, 2],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      const res = Game.merge("Left", input);
      const resMatrix = fromGrid(res);

      expect(resMatrix[0]).toEqual([4, 4, 0, 0]);
    });

    test("Left Move: Two pairs [2, 2, 4, 4] -> [4, 8, 0, 0]", () => {
      const input = toGrid([
        [2, 2, 4, 4],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      const res = Game.merge("Left", input);
      const resMatrix = fromGrid(res);

      expect(resMatrix[0]).toEqual([4, 8, 0, 0]);
    });

    test("Left Move: Gaps between identical tiles [2, 0, 2, 0] -> [4, 0, 0, 0]", () => {
      const input = toGrid([
        [2, 0, 2, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      const res = Game.merge("Left", input);
      const resMatrix = fromGrid(res);

      expect(resMatrix[0]).toEqual([4, 0, 0, 0]);
    });

    test("Right Move: Single pair merge right [0, 0, 2, 2] -> [0, 0, 0, 4]", () => {
      const input = toGrid([
        [0, 0, 2, 2],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      const res = Game.merge("Right", input);
      const resMatrix = fromGrid(res);

      expect(resMatrix[0]).toEqual([0, 0, 0, 4]);
    });

    test("Right Move: Four identical tiles right [2, 2, 2, 2] -> [0, 0, 4, 4]", () => {
      const input = toGrid([
        [2, 2, 2, 2],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      const res = Game.merge("Right", input);
      const resMatrix = fromGrid(res);

      expect(resMatrix[0]).toEqual([0, 0, 4, 4]);
    });

    test("Right Move: [0, 0, 4, 4] -> [0, 0, 0, 8]", () => {
      const input = toGrid([
        [0, 0, 4, 4],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      const res = Game.merge("Right", input);
      const resMatrix = fromGrid(res);

      expect(resMatrix[0]).toEqual([0, 0, 0, 8]);
    });
  });

  describe("2. Column Merging Rules (Up & Down)", () => {
    test("Up Move: merges column [2, 2, 2, 2] into [4, 4, 0, 0]", () => {
      const input = toGrid([
        [2, 0, 0, 0],
        [2, 0, 0, 0],
        [2, 0, 0, 0],
        [2, 0, 0, 0],
      ]);
      const res = Game.merge("Up", input);
      const resMatrix = fromGrid(res);

      expect(resMatrix[0][0]).toBe(4);
      expect(resMatrix[1][0]).toBe(4);
      expect(resMatrix[2][0]).toBe(0);
      expect(resMatrix[3][0]).toBe(0);
    });

    test("Down Move: merges column [2, 2, 2, 2] into [0, 0, 4, 4]", () => {
      const input = toGrid([
        [2, 0, 0, 0],
        [2, 0, 0, 0],
        [2, 0, 0, 0],
        [2, 0, 0, 0],
      ]);
      const res = Game.merge("Down", input);
      const resMatrix = fromGrid(res);

      expect(resMatrix[0][0]).toBe(0);
      expect(resMatrix[1][0]).toBe(0);
      expect(resMatrix[2][0]).toBe(4);
      expect(resMatrix[3][0]).toBe(4);
    });
  });

  describe("3. Engine Utilities & AI Solver", () => {
    test("detects full grid with no moves", () => {
      const fullGrid = toGrid([
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
      ]);

      expect(Game.isMergeable(fullGrid)).toBe(false);
      expect(Game.bestMove(fullGrid)).toBe(undefined);
    });

    test("correctly calculates score and max tile", () => {
      const grid = toGrid([
        [2, 4, 8, 16],
        [32, 64, 128, 256],
        [512, 1024, 2048, 0],
        [0, 0, 0, 0],
      ]);

      expect(Game.getMaxTile(grid)).toBe(2048);
      expect(Game.getScore(grid)).toBe(4094);
    });
  });
});
