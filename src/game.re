open Rationale;
open Rationale.Function.Infix;

type row = list(int);

type grid = list(row);

type position = {
  x: int,
  y: int,
};

type direction =
  | Left
  | Right
  | Up
  | Down;

let length_diff = (a, b) => List.length(a) - List.length(b);

let maybe_reverse = (reverse: bool, xs: row) => reverse ? List.rev(xs) : xs;

let get_position = (p: position) => List.nth(_, p.y) ||> List.nth(_, p.x);

let shift_zeroes = (xs: row) : row => {
  let filtered = xs |> List.filter(x => x !== 0);
  let pad = length_diff(xs, filtered) |> Array.make(_, 0) |> Array.to_list;

  pad @ filtered;
};

let find_zeroes =
  RList.fold_lefti(
    (acc, y) =>
      RList.fold_lefti(
        (acc', x, tile) => tile === 0 ? acc' @ [{y, x}] : acc',
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

let merge_grid = List.map(merge_row);

let merge = (direction: direction) : (grid => grid) =>
  switch (direction) {
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

let fill_random_empty_tile = (random_seed: int) => {
  Random.init(random_seed);

  (new_grid: grid) => {
    let new_cell_value = Random.int(100) < 90 ? 2 : 4;
    let update = update_grid(new_cell_value);

    switch (new_grid |> find_zeroes) {
    | [] => new_grid
    | [position] => update(position, new_grid)
    | empty_tiles =>
      let safe_index =
        switch (empty_tiles |> List.length |> Random.int) {
        | 0 => 0
        | i => i - 1
        };

      let random_position = List.nth(empty_tiles, safe_index);

      update(random_position, new_grid);
    };
  };
};