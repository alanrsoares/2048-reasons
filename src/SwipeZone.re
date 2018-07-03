open Utils;

type touchEvent = {
  x: float,
  y: float,
  timestamp: float,
};

type touchRecorder = {
  mutable touchStart: touchEvent,
  mutable touchEnd: touchEvent,
};

let get_touch_position = touches : touchEvent => {
  let touch = TouchList.first(touches);

  {x: touch##screenX, y: touch##screenY, timestamp: Js.Date.now()};
};

let component = ReasonReact.statelessComponent("SwipeZone");

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

let get_swipe_direction = ({touchStart, touchEnd}) : option(Game.direction) => {
  let min = 4000.0;

  let time_delta = touchEnd.timestamp -. touchStart.timestamp;
  let get_swipe_speed = (a, b) => (a -. b) *. 10000.0 /. time_delta;

  let y_speed = get_swipe_speed(touchEnd.y, touchStart.y);
  let x_speed = get_swipe_speed(touchEnd.x, touchStart.x);

  switch (abs_float(y_speed) > abs_float(x_speed)) {
  | true when y_speed -. min > 0.0 => Some(Game.Down)
  | true when y_speed +. min < 0.0 => Some(Game.Up)
  | false when x_speed -. min > 0.0 => Some(Game.Right)
  | false when x_speed +. min < 0.0 => Some(Game.Left)
  | _ => None
  };
};

let make = (~onSwipe: Game.direction => unit, children) => {
  let on_touch_start = event =>
    touchRecorder.touchStart =
      event |> ReactEventRe.Touch.targetTouches |> get_touch_position;

  let on_touch_end = event => {
    ReactEventRe.Touch.preventDefault(event);

    touchRecorder.touchEnd =
      event |> ReactEventRe.Touch.changedTouches |> get_touch_position;

    switch (touchRecorder |> get_swipe_direction) {
    | None => ()
    | Some(direction) => onSwipe(direction)
    };
  };
  {
    ...component,
    render: _self =>
      ReasonReact.createDomElement(
        "div",
        ~props={"onTouchStart": on_touch_start, "onTouchEnd": on_touch_end},
        children,
      ),
  };
};