open Utils;

type state = Game.grid;

type action =
  | Move(Game.direction)
  | Reset;

let empty_grid: Game.grid = [
  [0, 0, 0, 0],
  [0, 0, 0, 0],
  [0, 0, 0, 0],
  [0, 0, 0, 0],
];

let component = ReasonReact.reducerComponent("App");

type self = ReasonReact.self(Game.grid, ReasonReact.noRetainedProps, action);

let make = (~randomSeed, _children) => {
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

  let place_random_value = Game.fill_random_empty_tile(randomSeed);

  let initial_state = empty_grid |> place_random_value |> place_random_value;

  {
    ...component,
    initialState: () => initial_state,
    reducer: (action, state) =>
      switch (action) {
      | Move(direction) =>
        let merged = Game.merge(direction, state);
        let is_unchanged = merged == state;

        ReasonReact.Update(
          is_unchanged ? state : merged |> place_random_value,
        );
      | Reset => ReasonReact.Update(initial_state)
      },
    didMount: self => {
      let handler = self.handle(on_keyup);
      let event = "keyup";

      add_keyboard_event_listener(event, handler);
      self.onUnmount(() => remove_keyboard_event_listener(event, handler));
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
        <GithubForkRibbon />
      </div>,
  };
};