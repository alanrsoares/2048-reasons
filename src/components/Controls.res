// Controls.res - Action Bar Buttons using @styled-cva/react in ReScript v12

open StyledCva

type buttonMode = [#active | #idle]

module Toolbar = {
  let make = Tw.div("flex items-center gap-2 shrink-0")
}

module ActionButton = {
  type props = {...styledProps, @as("$state") state?: buttonMode}

  let make: React.component<props> = Tw.buttonWithConfig(
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
}

@react.component
let make = (~isAutoPlaying: bool, ~onToggleAutoPlay: unit => unit, ~onReset: unit => unit) => {
  <Toolbar>
    <ActionButton state={isAutoPlaying ? #active : #idle} onClick={_ => onToggleAutoPlay()}>
      {Utils.renderString(isAutoPlaying ? "Pause Auto" : "Auto Play")}
    </ActionButton>
    <ActionButton onClick={_ => onReset()}> {Utils.renderString("New Game")} </ActionButton>
  </Toolbar>
}
