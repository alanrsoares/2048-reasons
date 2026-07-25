// Utils.res - Utility Helpers in ReScript v12

let renderString = React.string
let renderArray = React.array
let renderList = xs => xs->List.toArray->renderArray

module TouchList = {
  external unsafeArrayToAny: 'a => array<'a> = "%identity"
  let hd = touchList => unsafeArrayToAny(touchList)[0]
}
