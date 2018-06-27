open Utils;

[%bs.raw {|require('./Grid.css')|}];

let component = ReasonReact.statelessComponent("Grid");

let make = (~seed: Game.grid, _children) => {
  ...component,
  render: _self =>
    <div className="Grid">
      (
        seed
        |> List.mapi((y, row) =>
             <div className="Grid-row" key=("row-" ++ string_of_int(y))>
               (
                 row
                 |> List.mapi((x, tile) =>
                      <div
                        className="Grid-tile"
                        key=("tile-" ++ string_of_int(x))>
                        (
                          ReasonReact.string(
                            tile > 0 ? string_of_int(tile) : "",
                          )
                        )
                      </div>
                    )
                 |> render_list
               )
             </div>
           )
        |> render_list
      )
    </div>,
};