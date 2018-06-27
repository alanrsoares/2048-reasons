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

let merge = (d: direction) =>
  switch (d) {
  | Right => merge_grid
  | Left => get_rows(true) ||> merge_grid ||> get_rows(true)
  | Up => get_cols(true) ||> merge_grid ||> get_cols(false) ||> List.rev
  | Down => get_cols(false) ||> merge_grid ||> get_cols(false)
  };