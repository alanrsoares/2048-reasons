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

test("get_columns", () => {
  let original = [[0, 0, 0, 0], [1, 0, 0, 0], [1, 0, 0, 0], [1, 0, 0, 0]];
  let expected = [[0, 1, 1, 1], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]];

  expect(Game.get_columns(false, original)) |> toEqual(expected);
});

test("get_columns:reverse", () => {
  let original = [[0, 0, 0, 0], [1, 0, 0, 0], [1, 0, 0, 0], [1, 0, 0, 0]];
  let expected = [[1, 1, 1, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]];

  expect(Game.get_columns(true, original)) |> toEqual(expected);
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