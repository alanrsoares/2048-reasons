open Jest;
open Expect;

type testCase('a, 'b) = {
  expected: 'a,
  value: 'b,
};

test("shift_zeroes", () => {
  let payload = [0, 1, 1, 0];
  let expected = [0, 0, 1, 1];

  expect(Game.shift_zeroes(payload)) |> toEqual(expected);
});

test("find_zeroes", () => {
  let payload = [[0, 1, 1, 1], [1, 1, 1, 1], [1, 1, 1, 1], [1, 1, 0, 1]];
  let expected: list(Game.position) = [{y: 0, x: 0}, {y: 3, x: 2}];

  expect(Game.find_zeroes(payload)) |> toEqual(expected);
});

describe("mergers: row", () => {
  test("merge_row_right", () => {
    let payload = [32, 0, 32, 0];
    let expected = [0, 0, 0, 64];

    expect(Game.merge_row_right(payload)) |> toEqual(expected);
  });

  test("merge_row_left", () => {
    let payload = [16, 16, 8, 0];
    let expected = [32, 8, 0, 0];

    expect(Game.merge_row_left(payload)) |> toEqual(expected);
  });
});

describe("mergers: grid", () => {
  test("merge: Left", () => {
    let payload = [
      [8, 0, 8, 2],
      [2, 0, 0, 2],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ];
    let expected = [
      [16, 2, 0, 0],
      [4, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ];

    expect(Game.merge(Game.Left, payload)) |> toEqual(expected);
  });

  test("merge: Right", () => {
    let payload = [
      [2, 0, 4, 0],
      [1, 0, 1, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ];
    let expected = [
      [0, 0, 2, 4],
      [0, 0, 0, 2],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ];

    expect(Game.merge(Game.Right, payload)) |> toEqual(expected);
  });

  test("merge: Up", () => {
    let payload = [
      [0, 2, 0, 0],
      [0, 2, 0, 0],
      [0, 4, 0, 0],
      [0, 4, 0, 0],
    ];
    let expected = [
      [0, 4, 0, 0],
      [0, 8, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ];

    expect(Game.merge(Game.Up, payload)) |> toEqual(expected);
  });

  test("merge: Down", () => {
    let payload = [
      [0, 2, 0, 0],
      [0, 2, 0, 0],
      [0, 4, 0, 0],
      [0, 4, 0, 0],
    ];
    let expected = [
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 4, 0, 0],
      [0, 8, 0, 0],
    ];

    expect(Game.merge(Game.Down, payload)) |> toEqual(expected);
  });
});