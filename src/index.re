[%bs.raw {|require('./index.css')|}];

[@bs.module "./registerServiceWorker"]
external register_service_worker : unit => unit = "default";

let randomSeed = Js.Date.now() |> int_of_float;

ReactDOMRe.renderToElementWithId(<App randomSeed />, "root");

register_service_worker();