// Controls.res - Action Bar Buttons in ReScript v12

@react.component
let make = (
  ~isAutoPlaying: bool,
  ~onToggleAutoPlay: unit => unit,
  ~onReset: unit => unit,
) => {
  <div className="flex items-center gap-2 shrink-0">
    /* Auto Bot Toggle Button */
    <button
      onClick={_ => onToggleAutoPlay()}
      className={
        "px-3.5 py-2 sm:px-4 sm:py-2.5 rounded-md font-bold text-xs sm:text-sm whitespace-nowrap transition-all active:scale-95 cursor-pointer shadow-xs " ++
        (if isAutoPlaying {
          "bg-[#f65e3b] text-[#f9f6f2] hover:bg-[#e14d2a] animate-pulse"
        } else {
          "bg-[#8f7a66] text-[#f9f6f2] hover:bg-[#7f6a56]"
        })
      }
    >
      {React.string(isAutoPlaying ? "Stop AI" : "Auto AI Bot")}
    </button>

    /* New Game Button */
    <button
      onClick={_ => onReset()}
      className="px-3.5 py-2 sm:px-4 sm:py-2.5 rounded-md bg-[#8f7a66] hover:bg-[#7f6a56] text-[#f9f6f2] font-bold text-xs sm:text-sm whitespace-nowrap shadow-xs transition-all active:scale-95 cursor-pointer"
    >
      {React.string("New Game")}
    </button>
  </div>
}
