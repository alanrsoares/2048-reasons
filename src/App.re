open Utils;

type state = Game.grid;

type action =
  | Move(Game.direction)
  | Reset;

let seed: Game.grid = [
  [0, 0, 0, 0],
  [0, 2, 0, 0],
  [0, 2, 2, 0],
  [0, 0, 0, 0],
];

let component = ReasonReact.reducerComponent("App");

type self = ReasonReact.self(Game.grid, ReasonReact.noRetainedProps, action);

let make_seed = () => Js.Date.now() |> int_of_float;

let make = _children => {
  let on_keyup = (event, self: self) => {
    let key = event |> ReactEventRe.Keyboard.key;

    switch (key) {
    | "ArrowUp" => self.send(Move(Up))
    | "ArrowDown" => self.send(Move(Down))
    | "ArrowLeft" => self.send(Move(Left))
    | "ArrowRight" => self.send(Move(Right))
    | _ => ()
    };
  };

  let random_seed = int_of_float(Js.Date.now());
  let place_random_value = Game.fill_random_zero(random_seed);

  {
    ...component,
    initialState: () => seed,
    reducer: (action, state) =>
      switch (action) {
      | Move(direction) =>
        ReasonReact.Update(
          Game.merge(direction, state) |> place_random_value(state),
        )
      | Reset => ReasonReact.Update(seed)
      },
    didMount: self => {
      let keyup_bound_handler = self.handle(on_keyup);

      add_keyboard_event_listener("keyup", keyup_bound_handler);
      self.onUnmount(() =>
        remove_keyboard_event_listener("keyup", keyup_bound_handler)
      );
    },
    render: self =>
      <div>
        <header>
          <h1 className="heading"> (render_string("2048 Reasons")) </h1>
        </header>
        <Grid data=self.state />
        <section className="hint">
          (render_string({js|use ←, ↑, → and ↓ to play|js}))
        </section>
      </div>,
  };
};