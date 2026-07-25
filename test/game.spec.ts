import { describe, expect, it } from "bun:test";
// Import compiled ReScript Game module
import * as Game from "../src/Game.res.js";

function makeTiles(matrix: number[][]): Game.tile[] {
  const tiles: Game.tile[] = [];
  let id = 1;
  for (let r = 0; r < 4; r++) {
    for (let c = 0; c < 4; c++) {
      const val = matrix[r][c];
      if (val !== 0) {
        tiles.push({
          id: id++,
          val,
          row: r,
          col: c,
          isNew: false,
          isMerged: false,
        });
      }
    }
  }
  return tiles;
}

function tilesToMatrix(tiles: Game.tile[]): number[][] {
  const m = [
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
  ];
  for (const t of tiles) {
    m[t.row][t.col] = t.val;
  }
  return m;
}

describe("2048 Game Rules & Merging Spec Harness (Blue-Green TDD)", () => {
  describe("1. Row Merging Rules (Left & Right)", () => {

    const leftCases = [
      {
        label: "Basic slide with no merge [0, 2, 0, 0] -> [2, 0, 0, 0]",
        input: [0, 2, 0, 0],
        expectedRow: [2, 0, 0, 0],
        expectedMoved: true,
        expectedScore: 0,
      },
      {
        label: "Single pair merge [2, 2, 0, 0] -> [4, 0, 0, 0]",
        input: [2, 2, 0, 0],
        expectedRow: [4, 0, 0, 0],
        expectedMoved: true,
        expectedScore: 4,
      },
      {
        label: "Triple identical tiles [2, 2, 2, 0] -> [4, 2, 0, 0]",
        input: [2, 2, 2, 0],
        expectedRow: [4, 2, 0, 0],
        expectedMoved: true,
        expectedScore: 4,
      },
      {
        label: "Four identical tiles [2, 2, 2, 2] -> [4, 4, 0, 0] (no double merge into 8)",
        input: [2, 2, 2, 2],
        expectedRow: [4, 4, 0, 0],
        expectedMoved: true,
        expectedScore: 8,
      },
      {
        label: "Two pairs [2, 2, 4, 4] -> [4, 8, 0, 0]",
        input: [2, 2, 4, 4],
        expectedRow: [4, 8, 0, 0],
        expectedMoved: true,
        expectedScore: 12,
      },
      {
        label: "Gaps between identical tiles [2, 0, 2, 0] -> [4, 0, 0, 0]",
        input: [2, 0, 2, 0],
        expectedRow: [4, 0, 0, 0],
        expectedMoved: true,
        expectedScore: 4,
      },
      {
        label: "Gaps across whole row [2, 0, 0, 2] -> [4, 0, 0, 0]",
        input: [2, 0, 0, 2],
        expectedRow: [4, 0, 0, 0],
        expectedMoved: true,
        expectedScore: 4,
      },
      {
        label: "Already compact row [4, 2, 8, 16] -> [4, 2, 8, 16] (no move)",
        input: [4, 2, 8, 16],
        expectedRow: [4, 2, 8, 16],
        expectedMoved: false,
        expectedScore: 0,
      },
      {
        label: "Middle pair merge [8, 4, 4, 2] -> [8, 8, 2, 0]",
        input: [8, 4, 4, 2],
        expectedRow: [8, 8, 2, 0],
        expectedMoved: true,
        expectedScore: 8,
      },
    ];

    it.each(leftCases)("Left Move: $label", ({ input, expectedRow, expectedMoved, expectedScore }) => {
      const grid = [
        input,
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      const tiles = makeTiles(grid);
      const res = Game.moveGrid(tiles, "Left", 100);

      expect(tilesToMatrix(res.tiles)[0]).toEqual(expectedRow);
      expect(res.moved).toBe(expectedMoved);
      expect(res.scoreGained).toBe(expectedScore);
    });

    const rightCases = [
      {
        label: "Basic slide right [0, 2, 0, 0] -> [0, 0, 0, 2]",
        input: [0, 2, 0, 0],
        expectedRow: [0, 0, 0, 2],
        expectedMoved: true,
        expectedScore: 0,
      },
      {
        label: "Single pair merge right [0, 0, 2, 2] -> [0, 0, 0, 4]",
        input: [0, 0, 2, 2],
        expectedRow: [0, 0, 0, 4],
        expectedMoved: true,
        expectedScore: 4,
      },
      {
        label: "Triple identical tiles right [0, 2, 2, 2] -> [0, 0, 2, 4]",
        input: [0, 2, 2, 2],
        expectedRow: [0, 0, 2, 4],
        expectedMoved: true,
        expectedScore: 4,
      },
      {
        label: "Four identical tiles right [2, 2, 2, 2] -> [0, 0, 4, 4]",
        input: [2, 2, 2, 2],
        expectedRow: [0, 0, 4, 4],
        expectedMoved: true,
        expectedScore: 8,
      },
      {
        label: "Two pairs right [4, 4, 2, 2] -> [0, 0, 8, 4]",
        input: [4, 4, 2, 2],
        expectedRow: [0, 0, 8, 4],
        expectedMoved: true,
        expectedScore: 12,
      },
    ];

    it.each(rightCases)("Right Move: $label", ({ input, expectedRow, expectedMoved, expectedScore }) => {
      const grid = [
        input,
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      const tiles = makeTiles(grid);
      const res = Game.moveGrid(tiles, "Right", 100);

      expect(tilesToMatrix(res.tiles)[0]).toEqual(expectedRow);
      expect(res.moved).toBe(expectedMoved);
      expect(res.scoreGained).toBe(expectedScore);
    });

  });

  describe("2. Column Merging Rules (Up & Down)", () => {
    it("Up Move: merges column [2, 2, 2, 2] into [4, 4, 0, 0]", () => {
      const grid = [
        [2, 0, 0, 0],
        [2, 0, 0, 0],
        [2, 0, 0, 0],
        [2, 0, 0, 0],
      ];
      const tiles = makeTiles(grid);
      const res = Game.moveGrid(tiles, "Up", 100);
      const m = tilesToMatrix(res.tiles);

      expect(m[0][0]).toBe(4);
      expect(m[1][0]).toBe(4);
      expect(m[2][0]).toBe(0);
      expect(m[3][0]).toBe(0);
      expect(res.moved).toBe(true);
      expect(res.scoreGained).toBe(8);
    });

    it("Down Move: merges column [2, 2, 2, 2] into [0, 0, 4, 4]", () => {
      const grid = [
        [2, 0, 0, 0],
        [2, 0, 0, 0],
        [2, 0, 0, 0],
        [2, 0, 0, 0],
      ];
      const tiles = makeTiles(grid);
      const res = Game.moveGrid(tiles, "Down", 100);
      const m = tilesToMatrix(res.tiles);

      expect(m[0][0]).toBe(0);
      expect(m[1][0]).toBe(0);
      expect(m[2][0]).toBe(4);
      expect(m[3][0]).toBe(4);
      expect(res.moved).toBe(true);
      expect(res.scoreGained).toBe(8);
    });
  });

  describe("3. Game Over & AI Solver (bestMove)", () => {
    it("detects when no valid moves remain (Full Grid with alternating values)", () => {
      const fullBlockedGrid = [
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
      ];
      const tiles = makeTiles(fullBlockedGrid);
      expect(Game.isMergeable(tiles)).toBe(false);
      expect(Game.bestMove(tiles)).toBeUndefined();
    });

    it("detects when merges are possible even on a full grid and finds best move", () => {
      const fullMergeableGrid = [
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 2, 2], // adjacent 2s in bottom row
      ];
      const tiles = makeTiles(fullMergeableGrid);
      expect(Game.isMergeable(tiles)).toBe(true);
      expect(Game.bestMove(tiles)).toBeDefined();
    });

    it("initializes state with exactly 2 random tiles", () => {
      const [tiles, nextId] = Game.createInitialState();
      expect(tiles.length).toBe(2);
      expect(nextId).toBe(3);
    });

    it("correctly calculates total score and max tile", () => {
      const grid = [
        [2, 4, 8, 16],
        [32, 64, 128, 256],
        [512, 1024, 2048, 0],
        [0, 0, 0, 0],
      ];
      const tiles = makeTiles(grid);
      expect(Game.getScore(tiles)).toBe(4094);
      expect(Game.getMaxTile(tiles)).toBe(2048);
    });
  });
});
