open Rationale;
open Rationale.Function.Infix;

type status =
  | New
  | Playng
  | AutoPlaying
  | Lost
  | Won;

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

let shift_zeroes = (xs: row) : row => {
  let (non_zeroes, zeroes) = xs |> RList.partition(x => x !== 0);

  zeroes @ non_zeroes;
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

let get_columns = (xs: grid) =>
  xs |> List.(mapi(x => mapi((y, _) => get_position({x, y}, xs))));

let merge_row_right = (xs: row) => {
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

let merge_row_left = List.rev ||> merge_row_right ||> List.rev;

let merge_grid_right = List.map(merge_row_right);

let merge_grid_left = List.map(merge_row_left);

let merge = (direction: direction) : (grid => grid) =>
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

type result = {
  direction,
  grid,
  score: int,
  zeroes: int,
};

let get_score =
  RList.(
    fold_lefti(
      (acc, _) => fold_lefti((acc', _, tile) => acc' + tile, acc),
      0,
    )
  );

let direction_to_string = direction =>
  switch (direction) {
  | Left => "left"
  | Right => "right"
  | Up => "up"
  | Down => "down"
  };

let grid_to_matrix = grid => {
  let matrix = Array.make_matrix(4, 4, 0);

  grid |> List.iteri(y => List.iteri((x, tile) => matrix[y][x] = tile));

  matrix;
};

let get_valid_moves = grid =>
  [Right, Up, Down, Left]
  |> List.map(direction => {
       let grid' = merge(direction, grid);
       let zeroes = find_zeroes(grid') |> List.length;
       {direction, zeroes, grid: grid', score: get_score(grid')};
     })
  |> List.filter(x => x.grid != grid);

let best_move =
  get_valid_moves
  ||> List.sort((a, b) => b.zeroes - a.zeroes)  /* more merges first */
  ||> List.sort((a, b) => b.score - a.score)  /* biggest score first */
  ||> (
    moves =>
      switch (List.length(moves)) {
      | 0 => None
      | _ => Some(moves |> List.hd |> (x => x.direction))
      }
  );

let is_mergeable =
  get_valid_moves
  ||> List.length
  ||> (
    len =>
      switch (len) {
      | 0 => false
      | _ => true
      }
  );