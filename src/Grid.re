open Utils;
open Rationale.Function.Infix;

[%bs.raw {|require('./Grid.css')|}];

let component = ReasonReact.statelessComponent("Grid");

let render_tiles =
  List.mapi((x, tile) =>
    <div className={j|Grid-tile tile-$tile|j} key={j|tile-$x|j}>
      (render_string(tile > 0 ? string_of_int(tile) : ""))
    </div>
  )
  ||> render_list;

let render_rows =
  List.mapi((y, row) =>
    <div className="Grid-row" key={j|row-$y|j}> (row |> render_tiles) </div>
  )
  ||> render_list;

let make = (~data: Game.grid, ~status: Game.status, _children) => {
  ...component,
  render: _self =>
    <div className="Grid-container">
      <div className="Grid"> (data |> render_rows) </div>
      (
        switch (status) {
        | Lost =>
          <div className="Grid-overlay">
            <div className="Grid-overlay-message">
              (render_string("game over"))
            </div>
          </div>
        | _ => <span />
        }
      )
    </div>,
};