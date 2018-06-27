open Utils;

let seed: Game.grid = [
  [0, 0, 0, 0],
  [0, 2, 0, 0],
  [0, 2, 2, 0],
  [0, 0, 0, 0],
];
let component = ReasonReact.statelessComponent("App");

let make = _children => {
  ...component,
  render: _self =>
    <div>
      <header>
        <h1 className="heading"> (render_string("2048")) </h1>
      </header>
      <div> <Grid seed /> </div>
      <section className="hint">
        (render_string("use kayboard arrow keys to play"))
      </section>
    </div>,
};