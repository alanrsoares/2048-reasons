// Controls.res - Action Bar Buttons using @styled-cva/react in ReScript v12

open StyledCva

let buttonVariants = cva(
  "px-3.5 py-2 sm:px-4 sm:py-2.5 rounded-md font-bold text-xs sm:text-sm whitespace-nowrap transition-all active:scale-95 cursor-pointer shadow-xs",
  {
    "variants": {
      "$state": {
        "active": "bg-[#f65e3b] text-[#f9f6f2] hover:bg-[#e14d2a] animate-pulse",
        "idle": "bg-[#8f7a66] text-[#f9f6f2] hover:bg-[#7f6a56]",
      },
    },
    "defaultVariants": {
      "$state": "idle",
    },
  },
)

@react.component
let make = (~isAutoPlaying: bool, ~onToggleAutoPlay: unit => unit, ~onReset: unit => unit) => {
  <div className="flex items-center gap-2 shrink-0">
    /* Auto-Play Toggle Button using @styled-cva/react variants */
    <button
      onClick={_ => onToggleAutoPlay()}
      className={buttonVariants({
        "$state": isAutoPlaying ? "active" : "idle",
      })}
    >
      {Utils.renderString(isAutoPlaying ? "Pause Auto" : "Auto Play")}
    </button>

    /* New Game Button */
    <button onClick={_ => onReset()} className={buttonVariants({"$state": "idle"})}>
      {Utils.renderString("New Game")}
    </button>
  </div>
}
