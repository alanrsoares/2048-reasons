// Grid.res - 4x4 Game Board Container using @styled-cva/react in ReScript v12

open StyledCva

type overlayOutcome = [#lost | #won]

module Board = {
  let make = Tw.div(
    "relative w-full max-w-[460px] aspect-square p-2 sm:p-3 rounded-2xl bg-[#bbada0] shadow-xl overflow-hidden",
  )
}

module SlotLayer = {
  let make = Tw.div("w-full h-full grid grid-cols-4 grid-rows-4")
}

module SlotCell = {
  let make = Tw.div("w-full h-full p-1.5 sm:p-2")
}

module Slot = {
  let make = Tw.div("w-full h-full rounded-xl bg-[#cdc1b4]/90")
}

module TileLayer = {
  let make = Tw.div("absolute inset-2 sm:inset-3 pointer-events-none")
}

module Overlay = {
  type props = {...styledProps, @as("$type") outcome?: overlayOutcome}

  let make: React.component<props> = Tw.divWithConfig(
    "absolute inset-0 rounded-2xl backdrop-blur-sm flex flex-col items-center justify-center p-6 text-center animate-pop-in z-30 pointer-events-auto",
    {
      "variants": {
        "$type": {
          "lost": "bg-[#faf8ef]/85",
          "won": "bg-[#edc22e]/85",
        },
      },
      "defaultVariants": {
        "$type": "lost",
      },
    },
  )
}

module OverlayHeading = {
  type props = {...styledProps, @as("$type") outcome?: overlayOutcome}

  let make: React.component<props> = Tw.h2WithConfig(
    "text-4xl sm:text-5xl font-black mb-2",
    {
      "variants": {
        "$type": {
          "lost": "text-[#776e65]",
          "won": "text-[#f9f6f2]",
        },
      },
      "defaultVariants": {
        "$type": "lost",
      },
    },
  )
}

module OverlayMessage = {
  type props = {...styledProps, @as("$type") outcome?: overlayOutcome}

  let make: React.component<props> = Tw.pWithConfig(
    "font-semibold text-sm mb-6",
    {
      "variants": {
        "$type": {
          "lost": "text-[#8f7a66] max-w-xs",
          "won": "text-[#f9f6f2]",
        },
      },
      "defaultVariants": {
        "$type": "lost",
      },
    },
  )
}

module RestartButton = {
  let make = Tw.button(
    "px-6 py-3 rounded-xl bg-[#8f7a66] hover:bg-[#7f6a56] text-[#f9f6f2] font-bold text-base shadow-md transition-all active:scale-95 cursor-pointer",
  )
}

type overlayContent = {
  outcome: overlayOutcome,
  heading: string,
  message: string,
  action: string,
}

let overlayFor = (status: Game.status): option<overlayContent> =>
  switch status {
  | Game.Lost =>
    Some({
      outcome: #lost,
      heading: "Game Over!",
      message: "No more moves left! Try again to beat your best score.",
      action: "Try Again",
    })
  | Game.Won =>
    Some({
      outcome: #won,
      heading: "You Hit 2048!",
      message: "You won! Keep playing to achieve an even higher score.",
      action: "Keep Going",
    })
  | Game.New | Game.Playing | Game.AutoPlaying => None
  }

@react.component
let make = (~tiles: array<Game.tile>, ~status: Game.status, ~onRestart: unit => unit) => {
  let emptyCells = Array.make(~length=16, 0)

  <Board>
    /* Static Background Grid Slots */
    <SlotLayer>
      {emptyCells
      ->Array.mapWithIndex((_, idx) => {
        <SlotCell key={"slot-" ++ Int.toString(idx)}>
          <Slot />
        </SlotCell>
      })
      ->Utils.renderArray}
    </SlotLayer>

    /* Dynamic Absolute Animated Tiles Container */
    <TileLayer>
      {tiles
      ->Array.map(t => {
        <Tile key={"tile-" ++ Int.toString(t.id)} tile={t} />
      })
      ->Utils.renderArray}
    </TileLayer>

    /* Game Over / Won Overlay */
    {switch overlayFor(status) {
    | Some({outcome, heading, message, action}) =>
      <Overlay outcome>
        <OverlayHeading outcome> {Utils.renderString(heading)} </OverlayHeading>
        <OverlayMessage outcome> {Utils.renderString(message)} </OverlayMessage>
        <RestartButton onClick={_ => onRestart()}> {Utils.renderString(action)} </RestartButton>
      </Overlay>
    | None => React.null
    }}
  </Board>
}
