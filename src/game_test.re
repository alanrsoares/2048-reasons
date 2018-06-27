open Jest;
open Expect;

test("shift_zeroes", () => {
  let original = [0, 1, 1, 0];
  let expected = [0, 0, 1, 1];

  expect(Game.shift_zeroes(original)) |> toEqual(expected);
});

test("merge_row", () => {
  let original = [0, 1, 1, 0];
  let expected = [0, 0, 0, 2];

  expect(Game.merge_row(original)) |> toEqual(expected);
});

test("get_cols", () => {
  let original = [[0, 0, 0, 0], [1, 0, 0, 0], [1, 0, 0, 0], [1, 0, 0, 0]];
  let expected = [[0, 1, 1, 1], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]];

  expect(Game.get_cols(false, original)) |> toEqual(expected);
});

test("get_cols:reverse", () => {
  let original = [[0, 0, 0, 0], [1, 0, 0, 0], [1, 0, 0, 0], [1, 0, 0, 0]];
  let expected = [[1, 1, 1, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]];

  expect(Game.get_cols(true, original)) |> toEqual(expected);
});

test("get_rows", () => {
  let original = [[0, 0, 0, 0], [1, 0, 0, 0], [1, 0, 0, 0], [1, 0, 0, 0]];
  let expected = [[0, 0, 0, 0], [1, 0, 0, 0], [1, 0, 0, 0], [1, 0, 0, 0]];

  expect(Game.get_rows(false, original)) |> toEqual(expected);
});

test("get_rows:reverse", () => {
  let original = [[0, 0, 0, 0], [1, 0, 0, 0], [1, 0, 0, 0], [1, 0, 0, 0]];
  let expected = [[0, 0, 0, 0], [0, 0, 0, 1], [0, 0, 0, 1], [0, 0, 0, 1]];

  expect(Game.get_rows(true, original)) |> toEqual(expected);
});

test("merge_grid", () => {
  let original = [[2, 0, 4, 0], [1, 0, 1, 0], [0, 0, 0, 0], [0, 0, 0, 0]];
  let expected = [[0, 0, 2, 4], [0, 0, 0, 2], [0, 0, 0, 0], [0, 0, 0, 0]];

  expect(Game.merge_grid(original)) |> toEqual(expected);
});

test("merge:Right", () => {
  let original = [[2, 0, 4, 0], [1, 0, 1, 0], [0, 0, 0, 0], [0, 0, 0, 0]];
  let expected = [[0, 0, 2, 4], [0, 0, 0, 2], [0, 0, 0, 0], [0, 0, 0, 0]];

  expect(Game.merge(Game.Right, original)) |> toEqual(expected);
});

test("merge:Left", () => {
  let original = [[2, 0, 4, 0], [1, 0, 1, 0], [0, 0, 0, 0], [0, 0, 0, 0]];
  let expected = [[2, 4, 0, 0], [2, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]];

  expect(Game.merge(Game.Left, original)) |> toEqual(expected);
});

test("merge:Up", () => {
  let original = [[0, 2, 0, 0], [0, 2, 0, 0], [0, 4, 0, 0], [0, 4, 0, 0]];
  let expected = [[0, 4, 0, 0], [0, 8, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]];

  expect(Game.merge(Game.Up, original)) |> toEqual(expected);
});

test("merge:Down", () => {
  let original = [[0, 2, 0, 0], [0, 2, 0, 0], [0, 4, 0, 0], [0, 4, 0, 0]];
  let expected = [[0, 0, 0, 0], [0, 0, 0, 0], [0, 4, 0, 0], [0, 8, 0, 0]];

  expect(Game.merge(Game.Down, original)) |> toEqual(expected);
});