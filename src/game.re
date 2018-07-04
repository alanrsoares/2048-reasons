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

let length_diff = (a, b) => List.(length(a) - length(b));

let get_position = (p: position) => List.(nth(_, p.y) ||> nth(_, p.x));

let push_zeroes = (xs: row) : row => {
  let (non_zeroes, zeroes) = xs |> RList.partition(x => x !== 0);

  non_zeroes @ zeroes;
};

let find_zeroes =
  RList.(
    fold_lefti(
      (acc, y) =>
        fold_lefti(
          (acc', x, tile) => tile === 0 ? acc' @ [{y, x}] : acc',
          acc,
        ),
      [],
    )
  );

let get_columns = xs =>
  xs |> List.(mapi(x => mapi((y, _) => get_position({x, y}, xs))));

let fold_selfi = (f, xs) => xs |> RList.fold_lefti(f, xs);

let swap_left = (x, i) => RList.(update(x, i - 1) ||> update(0, i));

let merge_row_left =
  push_zeroes
  ||> fold_selfi((xs, i, x) =>
        switch (i) {
        | 0 => xs
        | _ =>
          let y = List.nth(xs, i - 1);
          x !== y ? xs : xs |> swap_left(x + y, i) |> push_zeroes;
        }
      );

let merge_row_right = List.(rev ||> merge_row_left ||> rev);

let merge_grid_right = List.map(merge_row_right);

let merge_grid_left = List.map(merge_row_left);

let merge = (direction: direction) =>
  switch (direction) {
  | Right => merge_grid_right
  | Left => merge_grid_left
  | Up => get_columns ||> merge_grid_left ||> get_columns
  | Down => get_columns ||> merge_grid_right ||> get_columns
  };

let update_grid = (value: int, zero: position, grid: grid) => {
  let old_row = List.nth(grid, zero.y);
  let new_row = old_row |> RList.update(value, zero.x);

  grid |> RList.update(new_row, zero.y);
};

let fill_random_empty_tile = (random_seed: int) => {
  Random.init(random_seed);

  (grid: grid) => {
    let position =
      switch (grid |> find_zeroes) {
      | [] => None
      | [first_position] => Some(first_position)
      | empty_tiles =>
        let safe_index =
          switch (empty_tiles |> List.length |> Random.int) {
          | 0 => 0
          | i => i - 1
          };

        Some(List.nth(empty_tiles, safe_index));
      };

    switch (position) {
    | None => None
    | Some(safe_position) =>
      let new_tile_value = Random.int(100) < 90 ? 2 : 4;
      Some(update_grid(new_tile_value, safe_position, grid));
    };
  };
};