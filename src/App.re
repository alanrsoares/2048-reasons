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

type touchRecorder = {
  mutable touchStart: Game.touchEvent,
  mutable touchEnd: Game.touchEvent,
};

let touchRecorder = {
  touchStart: {
    x: 0.0,
    y: 0.0,
    timestamp: 0.0,
  },
  touchEnd: {
    x: 0.0,
    y: 0.0,
    timestamp: 0.0,
  },
};

let get_swipe_direction = () : option(Game.direction) => {
  let min = 4000.0;
  let tr = touchRecorder;

  let get_speed = (a, b) =>
    (a -. b) *. 10000.0 /. (tr.touchEnd.timestamp -. tr.touchStart.timestamp);

  let down = get_speed(tr.touchEnd.y, tr.touchStart.y);
  let right = get_speed(tr.touchEnd.x, tr.touchStart.x);

  let gesture = ref(None);

  if ((down > 0.0 ? down : -. down) > (right > 0.0 ? right : -. right)) {
    if (down -. min > 0.0) {
      gesture := Some(Game.Down);
    };
    if (down +. min < 0.0) {
      gesture := Some(Game.Up);
    };
  } else {
    if (right -. min > 0.0) {
      gesture := Some(Game.Right);
    };
    if (right +. min < 0.0) {
      gesture := Some(Game.Left);
    };
  };

  gesture^;
};

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

  let on_touch_start = (event, _self) =>
    touchRecorder.touchStart =
      get_touch_position(event |> ReactEventRe.Touch.targetTouches);

  let on_touch_end = (event, self: self) => {
    touchRecorder.touchEnd =
      get_touch_position(event |> ReactEventRe.Touch.changedTouches);

    switch (get_swipe_direction()) {
    | None => ()
    | Some(direction) => self.send(Move(direction))
    };
  };

  let place_random_value = Game.fill_random_empty_tile(randomSeed);

  let maybe_place_value = grid =>
    switch (grid |> place_random_value) {
    | None => grid
    | Some(new_grid) => new_grid
    };

  let initial_state = empty_grid |> maybe_place_value |> maybe_place_value;

  {
    ...component,
    initialState: () => initial_state,
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
        <div
          onTouchStart=(self.handle(on_touch_start))
          onTouchEnd=(self.handle(on_touch_end))>
          <Grid data=self.state />
        </div>
        <section className="hint">
          (render_string({js|use ←, ↑, → and ↓ to play|js}))
        </section>
        <GithubForkRibbon />
      </div>,
  };
};