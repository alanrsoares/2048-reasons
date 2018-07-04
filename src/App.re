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

type self = ReasonReact.self(state, ReasonReact.noRetainedProps, action);

let make = (~randomSeed, _children) => {
  let on_keyup = (event, self: self) => {
    let key = event |> ReactEventRe.Keyboard.key;

    switch (key) {
    | "ArrowUp" => self.send(Move(Up))
    | "ArrowDown" => self.send(Move(Down))
    | "ArrowLeft" => self.send(Move(Left))
    | "ArrowRight" => self.send(Move(Right))
    /* enables auto move */
    /* | "q" =>
       let direction = Game.best_move(self.state);

       Js.log2(
         direction |> Game.direction_to_string,
         self.state |> Game.grid_to_matrix,
       );

       self.send(Move(direction)); */
    | _ => ()
    };
  };

  let place_random_value = Game.fill_random_empty_tile(randomSeed);

  let maybe_place_value = grid =>
    switch (grid |> place_random_value) {
    | None => grid
    | Some(new_grid) => new_grid
    };

  let make_initial_state = () =>
    empty_grid |> maybe_place_value |> maybe_place_value;

  {
    ...component,
    initialState: () => make_initial_state(),
    reducer: (action, state) =>
      switch (action) {
      | Move(direction) =>
        let new_grid = Game.merge(direction, state);

        if (new_grid == state) {
          ReasonReact.NoUpdate;
        } else {
          switch (new_grid |> place_random_value) {
          | Some(new_grid') => ReasonReact.Update(new_grid')
          | None => ReasonReact.NoUpdate /* GAME_OVER! */
          };
        };
      | Reset => ReasonReact.Update(make_initial_state())
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
          <h1 className="heading">
            (render_string("2048 "))
            <span className="reason">
              <span className="re"> (render_string("RE")) </span>
              (render_string("ASONS"))
            </span>
          </h1>
        </header>
        <div className="controls">
          <button
            className="new-game"
            onClick=(_ => self.send(Reset))
            onTouchEnd=(_ => self.send(Reset))>
            (render_string("New Game"))
          </button>
        </div>
        <SwipeZone onSwipe=(direction => self.send(Move(direction)))>
          <Grid data=self.state />
        </SwipeZone>
        <section className="hint">
          (render_string({js|use ←, ↑, → and ↓ to play|js}))
        </section>
      </div>,
  };
};