open Utils;

type state = {
  grid: Game.grid,
  gameStatus: Game.status,
  isPlaying: bool,
  animationFrameId: ref(option(Webapi.rafId)),
};

type action =
  | Move(Game.direction)
  | Tick
  | Start
  | Stop(Webapi.rafId)
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
  let on_keyup = (event, self: self) =>
    switch (event |> Webapi.Dom.KeyboardEvent.key) {
    | "ArrowUp" => self.send(Move(Up))
    | "ArrowDown" => self.send(Move(Down))
    | "ArrowLeft" => self.send(Move(Left))
    | "ArrowRight" => self.send(Move(Right))
    | "q" => self.send(Tick)
    | _ => ()
    };

  let on_toggle_autoplay = (_, self: self) => {
    let rec play = _ => {
      self.state.animationFrameId :=
        Some(Webapi.requestCancellableAnimationFrame(play));
      self.send(Tick);
    };

    switch (self.state.animationFrameId^) {
    | None =>
      play(0.);
      self.send(Start);
    | Some(rafId) => self.send(Stop(rafId))
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
    gameStatus: New,
    animationFrameId: ref(None),
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
          Game.is_mergeable(new_grid) ?
            ReasonReact.NoUpdate :
            ReasonReact.Update({...state, gameStatus: Lost});
        } else {
          switch (new_grid |> place_random_value) {
          | Some(new_grid') =>
            ReasonReact.Update({...state, grid: new_grid'})
          | None => ReasonReact.Update({...state, gameStatus: Lost})
          };
        };
      | Tick =>
        let direction = Game.best_move(state.grid);

        switch (direction) {
        | None =>
          switch (state.animationFrameId^) {
          | None =>
            ReasonReact.Update({...state, gameStatus: Lost, isPlaying: false})
          | Some(rafId) =>
            Webapi.cancelAnimationFrame(rafId);
            ReasonReact.Update({
              ...state,
              gameStatus: Lost,
              isPlaying: false,
            });
          }
        | Some(direction') =>
          ReasonReact.SideEffects((self => self.send(Move(direction'))))
        };
      | Start => ReasonReact.Update({...state, isPlaying: true})
      | Stop(rafId) =>
        Webapi.cancelAnimationFrame(rafId);

        ReasonReact.Update({
          ...state,
          isPlaying: false,
          animationFrameId: ref(None),
        });
      | Reset => ReasonReact.Update(make_initial_state())
      },
    didMount: self => {
      let handler = self.handle(on_keyup);

      Webapi.Dom.(Document.addKeyUpEventListener(handler, document));

      self.onUnmount(() =>
        Webapi.Dom.(Document.removeKeyUpEventListener(handler, document))
      );
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
            switch (Env.node_env) {
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
          <Grid data=self.state.grid status=self.state.gameStatus />
        </SwipeZone>
        <section className="hint">
          (render_string({js|use ←, ↑, → and ↓ to play|js}))
        </section>
      </div>,
  };
};