open Utils;

let component = ReasonReact.statelessComponent("GithubForkRibbon");

let project_url = "https://github.com/alanrsoares/2048-reasons";

let renderRibbon = extraClasses =>
  <div className=("github-fork-ribbon-wrapper " ++ extraClasses)>
    <div className="github-fork-ribbon">
      <a href=project_url> (render_string("Fork me on Github")) </a>
    </div>
  </div>;

let make = _children => {
  ...component,
  render: _self => <div> (renderRibbon("right")) </div>,
};