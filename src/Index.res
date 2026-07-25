// Index.res - Modern React 19 Entry Point in ReScript v12

%%raw(`import './index.css'`)

switch ReactDOM.querySelector("#root") {
| Some(rootElement) =>
  let root = ReactDOM.Client.createRoot(rootElement)
  root->ReactDOM.Client.Root.render(<App />)
| None => ()
}
