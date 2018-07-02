open Utils;
open Rationale.Function.Infix;

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
  let get_speed = (a, b) => (a -. b) *. 10000.0 /. time_delta;

  let down = get_speed(touchEnd.y, touchStart.y);
  let right = get_speed(touchEnd.x, touchStart.x);

  let gesture = ref(None);

  Js.log2(down, right);

  if (abs_float(down) > abs_float(right)) {
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