[@bs.val] external environment : string = "process.env.NODE_ENV";

[@bs.val]
external request_animation_frame : (unit => unit) => int =
  "requestAnimationFrame";

[@bs.val]
external cancel_animation_frame : int => unit = "cancelAnimationFrame";

[@bs.val]
external add_keyboard_event_listener :
  (string, ReactEventRe.Keyboard.t => unit) => unit =
  "addEventListener";

[@bs.val]
external remove_keyboard_event_listener :
  (string, ReactEventRe.Keyboard.t => unit) => unit =
  "removeEventListener";

[@bs.val]
external add_touch_event_listener :
  (string, ReactEventRe.Touch.t => unit) => unit =
  "addEventListener";

[@bs.val]
external remove_touch_event_listener :
  (string, ReactEventRe.Touch.t => unit) => unit =
  "removeEventListener";

let render_string = ReasonReact.string;

let render_array = ReasonReact.array;

let render_list = xs => xs |> Array.of_list |> render_array;

let make_style = ReactDOMRe.Style.make;

let identity = x => x;

module TouchList = {
  external unsafeAnyToArray : 'a => array('a) = "%identity";
  let first = touchlist => unsafeAnyToArray(touchlist)[0];
};