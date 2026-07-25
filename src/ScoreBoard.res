// ScoreBoard.res - Score Cards Component using @styled-cva/react in ReScript v12

open StyledCva

let scoreLabelClass = cn([
  "text-[9px] sm:text-[10px] font-black uppercase tracking-wider text-[#eee4da]",
])

let scoreValueClass = cn(["text-base sm:text-lg font-black text-white leading-none"])

let cardClass = cn([
  "bg-[#bbada0] px-3 py-1.5 sm:px-4 sm:py-2 rounded-md flex flex-col items-center justify-center min-w-[64px] sm:min-w-[76px] shadow-xs",
])

@react.component
let make = (~score: int, ~bestScore: int) => {
  <div className="flex items-center gap-1.5 sm:gap-2">
    /* Current Score Card */
    <div className={cardClass}>
      <span className={scoreLabelClass}> {Utils.renderString("SCORE")} </span>
      <span className={scoreValueClass}> {React.int(score)} </span>
    </div>

    /* Best Score Card */
    <div className={cardClass}>
      <span className={scoreLabelClass}> {Utils.renderString("BEST")} </span>
      <span className={scoreValueClass}> {React.int(bestScore)} </span>
    </div>
  </div>
}
