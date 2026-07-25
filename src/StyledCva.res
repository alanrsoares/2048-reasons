// StyledCva.res - ReScript v12 Bindings for @styled-cva/react

@module("@styled-cva/react") @variadic
external cn: array<string> => string = "cn"

@module("@styled-cva/react")
external cva: (string, 'config) => 'props => string = "cva"

module Tw = {
  @module("@styled-cva/react") @scope("default")
  external button: (string, 'config) => React.component<'props> = "button"

  @module("@styled-cva/react") @scope("default")
  external div: (string, 'config) => React.component<'props> = "div"

  @module("@styled-cva/react") @scope("default")
  external span: (string, 'config) => React.component<'props> = "span"

  @module("@styled-cva/react") @scope("default")
  external a: (string, 'config) => React.component<'props> = "a"

  @module("@styled-cva/react") @scope("default")
  external p: (string, 'config) => React.component<'props> = "p"

  @module("@styled-cva/react") @scope("default")
  external section: (string, 'config) => React.component<'props> = "section"

  @module("@styled-cva/react") @scope("default")
  external header: (string, 'config) => React.component<'props> = "header"

  @module("@styled-cva/react") @scope("default")
  external footer: (string, 'config) => React.component<'props> = "footer"
}
