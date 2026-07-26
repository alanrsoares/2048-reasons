// ScoreBoard.res - Score Cards Component using @styled-cva/react Tw styled components in ReScript v12

open StyledCva

let scoreCard = Tw.div(
  "bg-[#bbada0] px-3 py-1.5 sm:px-4 sm:py-2 rounded-md flex flex-col items-center justify-center min-w-[64px] sm:min-w-[76px] shadow-xs",
)

let scoreLabel = Tw.span(
  "text-[9px] sm:text-[10px] font-black uppercase tracking-wider text-[#eee4da]",
)

let scoreValue = Tw.span("text-base sm:text-lg font-black text-white leading-none")

@react.component
let make = (~score: int, ~bestScore: int) => {
  <div className="flex items-center gap-1.5 sm:gap-2">
    /* Current Score Card */
    {React.createElement(
      scoreCard,
      {
        children: React.array([
          React.createElement(scoreLabel, {children: Utils.renderString("SCORE")}),
          React.createElement(scoreValue, {children: React.int(score)}),
        ]),
      },
    )}

    /* Best Score Card */
    {React.createElement(
      scoreCard,
      {
        children: React.array([
          React.createElement(scoreLabel, {children: Utils.renderString("BEST")}),
          React.createElement(scoreValue, {children: React.int(bestScore)}),
        ]),
      },
    )}
  </div>
}
