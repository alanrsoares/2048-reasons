// ScoreBoard.res - Score Cards Component using @styled-cva/react Tw styled components in ReScript v12

open StyledCva

module ScoreCard = {
  let make = Tw.div(
    "bg-[#bbada0] px-3 py-1.5 sm:px-4 sm:py-2 rounded-md flex flex-col items-center justify-center min-w-[64px] sm:min-w-[76px] shadow-xs",
  )
}

module ScoreLabel = {
  let make = Tw.span("text-[9px] sm:text-[10px] font-black uppercase tracking-wider text-[#eee4da]")
}

module ScoreValue = {
  let make = Tw.span("text-base sm:text-lg font-black text-white leading-none")
}

@react.component
let make = (~score: int, ~bestScore: int) => {
  <div className="flex items-center gap-1.5 sm:gap-2">
    <ScoreCard>
      <ScoreLabel> {Utils.renderString("SCORE")} </ScoreLabel>
      <ScoreValue> {React.int(score)} </ScoreValue>
    </ScoreCard>
    <ScoreCard>
      <ScoreLabel> {Utils.renderString("BEST")} </ScoreLabel>
      <ScoreValue> {React.int(bestScore)} </ScoreValue>
    </ScoreCard>
  </div>
}
