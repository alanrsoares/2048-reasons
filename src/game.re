open Rationale;
open Rationale.Function.Infix;

type row = list(int);

type grid = list(row);

type position = {
  x: int,
  y: int,
};

let length_diff = (a, b) => List.length(a) - List.length(b);

let maybe_reverse = (reverse: bool, xs: row) => reverse ? List.rev(xs) : xs;

let get_position = (p: position, g: grid) =>
  g |> List.nth(_, p.y) |> List.nth(_, p.x);

let shift_zeroes = (xs: row) : row => {
  let ys = xs |> List.filter(x => x !== 0);
  let pad = length_diff(xs, ys) |> Array.make(_, 0) |> Array.to_list;

  List.append(pad, ys);
};

let find_zeroes = (xs: grid) : list(position) =>
  xs
  |> RList.fold_lefti(
       (acc, y, row) =>
         row
         |> RList.fold_lefti(
              (acc', x, tile) =>
                tile === 0 ? List.append(acc', [{y, x}]) : acc',
              acc,
            ),
       [],
     );

let get_cols = (reverse: bool, xs: grid) =>
  xs
  |> List.(mapi(x => mapi((y, _) => get_position({x, y}, xs))))
  |> List.map(maybe_reverse(reverse));

let get_rows = (reverse: bool, xs: grid) =>
  xs |> List.map(maybe_reverse(reverse));

let merge_row = (xs: row) => {
  let rec merge = (index: int, ys: row) =>
    switch (ys) {
    | [a, b, c, d] =>
      switch (index) {
      | 0 => merge(1, c === d ? [0, a, b, c + d] : ys)
      | 1 => merge(2, b === c ? [0, a, b + c, d] : ys)
      | 2 => merge(3, a === b ? [0, a + b, c, d] : ys)
      | _ => ys
      }
    | _ => ys
    };

  xs |> shift_zeroes |> merge(0);
};

let merge_grid = (g: grid) => g |> List.map(merge_row);

type direction =
  | Left
  | Right
  | Up
  | Down;

let merge = (d: direction) : (grid => grid) =>
  switch (d) {
  | Right => merge_grid
  | Left => get_rows(true) ||> merge_grid ||> get_rows(true)
  | Up => get_cols(true) ||> merge_grid ||> get_cols(false) ||> List.rev
  | Down => get_cols(false) ||> merge_grid ||> get_cols(false)
  };

let update_grid = (value: int, zero: position, grid: grid) => {
  let old_row = List.nth(grid, zero.y);
  let new_row = old_row |> RList.update(value, zero.x);

  grid |> RList.update(new_row, zero.y);
};

let fill_random_zero = (random_seed: int) => {
  Random.init(random_seed);

  (old_grid: grid, new_grid: grid) =>
    if (old_grid == new_grid) {
      old_grid;
    } else {
      let zeroes = new_grid |> find_zeroes;
      let zero = List.nth(zeroes, Random.int(List.length(zeroes) - 1));

      update_grid(2, zero, new_grid);
    };
};