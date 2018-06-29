[%bs.raw {|require('./index.css')|}];

[@bs.module "./registerServiceWorker"]
external register_service_worker : unit => unit = "default";

ReactDOMRe.renderToElementWithId(
  <App randomSeed=(int_of_float(Js.Date.now())) />,
  "root",
);

register_service_worker();