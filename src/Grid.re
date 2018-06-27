open Utils;
open Rationale.Function.Infix;

[%bs.raw {|require('./Grid.css')|}];

let component = ReasonReact.statelessComponent("Grid");

let render_tiles =
  List.mapi((x, tile) =>
    <div className="Grid-tile" key=("tile-" ++ string_of_int(x))>
      (render_string(tile > 0 ? string_of_int(tile) : ""))
    </div>
  )
  ||> render_list;

let render_rows =
  List.mapi((y, row) =>
    <div className="Grid-row" key=("row-" ++ string_of_int(y))>
      (row |> render_tiles)
    </div>
  )
  ||> render_list;

let make = (~seed: Game.grid, _children) => {
  ...component,
  render: _self => <div className="Grid"> (seed |> render_rows) </div>,
};