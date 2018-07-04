open Jest;
open Expect;

test("push_zeroes", () => {
  let original = [0, 1, 1, 0];
  let expected = [1, 1, 0, 0];

  expect(Game.push_zeroes(original)) |> toEqual(expected);
});

test("find_zeroes", () => {
  let original = [[0, 1, 1, 1], [1, 1, 1, 1], [1, 1, 1, 1], [1, 1, 0, 1]];
  let expected: list(Game.position) = [{y: 0, x: 0}, {y: 3, x: 2}];

  expect(Game.find_zeroes(original)) |> toEqual(expected);
});

test("merge_row_right", () => {
  let original = [0, 1, 1, 0];
  let expected = [0, 0, 0, 2];

  expect(Game.merge_row_right(original)) |> toEqual(expected);
});

test("merge_row_left", () => {
  let original = [2, 0, 2, 0];
  let expected = [4, 0, 0, 0];

  expect(Game.merge_row_left(original)) |> toEqual(expected);
});

test("get_columns", () => {
  let original = [[0, 0, 0, 0], [1, 0, 0, 0], [1, 0, 0, 0], [1, 0, 0, 0]];
  let expected = [[0, 1, 1, 1], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]];

  expect(Game.get_columns(original)) |> toEqual(expected);
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