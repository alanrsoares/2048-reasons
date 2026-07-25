// ScoreBoard.res - Classic 2048 Score Badges in ReScript v12

@react.component
let make = (~score: int, ~bestScore: int) => {
  <div className="flex items-center gap-2 shrink-0">
    /* Current Score Box */
    <div
      className="flex flex-col items-center justify-center min-w-[72px] sm:min-w-[84px] px-3 py-1.5 sm:py-2 rounded-md bg-[#bbada0] text-center shadow-xs"
    >
      <span className="text-[11px] font-extrabold uppercase tracking-wider text-[#eee4da]">
        {React.string("SCORE")}
      </span>
      <span className="text-xl sm:text-2xl font-black text-white leading-none mt-1">
        {React.int(score)}
      </span>
    </div>

    /* Best Score Box */
    <div
      className="flex flex-col items-center justify-center min-w-[72px] sm:min-w-[84px] px-3 py-1.5 sm:py-2 rounded-md bg-[#bbada0] text-center shadow-xs"
    >
      <span className="text-[11px] font-extrabold uppercase tracking-wider text-[#eee4da]">
        {React.string("BEST")}
      </span>
      <span className="text-xl sm:text-2xl font-black text-white leading-none mt-1">
        {React.int(bestScore)}
      </span>
    </div>
  </div>
}
