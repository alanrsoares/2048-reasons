let render_string = ReasonReact.string;

let render_array = ReasonReact.array;

let render_list = xs => xs |> Array.of_list |> render_array;

module TouchList = {
  external unsafe_array_to_any : 'a => array('a) = "%identity";
  let hd = touchlist => unsafe_array_to_any(touchlist)[0];
};

module Env = {
  [@bs.val] external node_env : string = "process.env.NODE_ENV";
};