open Utils;

type game_status =
  | New
  | Playng
  | AutoPlaying
  | Lost
  | Won;

type state = {
  grid: Game.grid,
  game_status,
  isPlaying: bool,
  animationFrameId: ref(int),
};

type action =
  | Move(Game.direction)
  | Tick
  | Start
  | Stop
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
    | "q" => self.send(Tick)
    | _ => ()
    };
  };

  let on_toggle_autoplay = (_, self: self) => {
    let rec play = () => {
      self.state.animationFrameId := request_animation_frame(play);
      self.send(Tick);
    };
    if (self.state.isPlaying) {
      cancel_animation_frame(self.state.animationFrameId^);
      self.send(Stop);
    } else {
      play();
      self.send(Start);
    };
  };

  let place_random_value = Game.fill_random_empty_tile(randomSeed);

  let maybe_place_value = grid =>
    switch (grid |> place_random_value) {
    | None => grid
    | Some(new_grid) => new_grid
    };

  let make_initial_state = () => {
    grid: empty_grid |> maybe_place_value |> maybe_place_value,
    game_status: New,
    animationFrameId: ref(0),
    isPlaying: false,
  };

  {
    ...component,
    initialState: () => make_initial_state(),
    reducer: (action, state) =>
      switch (action) {
      | Move(direction) =>
        let new_grid = Game.merge(direction, state.grid);

        if (new_grid == state.grid) {
          ReasonReact.NoUpdate;
        } else {
          switch (new_grid |> place_random_value) {
          | Some(new_grid') =>
            ReasonReact.Update({...state, grid: new_grid'})
          | None => ReasonReact.NoUpdate /* GAME_OVER! */
          };
        };
      | Tick =>
        let direction = Game.best_move(state.grid);

        switch (direction) {
        | None => ReasonReact.NoUpdate
        | Some(direction') =>
          let new_grid = Game.merge(direction', state.grid);

          if (new_grid == state.grid) {
            ReasonReact.NoUpdate;
          } else {
            switch (new_grid |> place_random_value) {
            | Some(new_grid') =>
              ReasonReact.Update({...state, grid: new_grid'})
            | None => ReasonReact.NoUpdate /* GAME_OVER! */
            };
          };
        };
      | Start => ReasonReact.Update({...state, isPlaying: true})
      | Stop => ReasonReact.Update({...state, isPlaying: false})
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
          (
            switch (Utils.environment) {
            | "development" =>
              <button
                className="new-game"
                onClick=(self.handle(on_toggle_autoplay))>
                (render_string(self.state.isPlaying ? "Stop" : "Auto"))
              </button>
            | _ => <span />
            }
          )
          <button
            className="new-game"
            onClick=(_ => self.send(Reset))
            onTouchEnd=(_ => self.send(Reset))>
            (render_string("New Game"))
          </button>
        </div>
        <SwipeZone onSwipe=(direction => self.send(Move(direction)))>
          <Grid data=self.state.grid />
        </SwipeZone>
        <section className="hint">
          (render_string({js|use ←, ↑, → and ↓ to play|js}))
        </section>
      </div>,
  };
};