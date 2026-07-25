// Grid.res - 4x4 Game Board Container using @styled-cva/react in ReScript v12

open StyledCva

type overlayProps = {"$type": string}

let overlayVariants: overlayProps => string = cva(
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

let overlayHeadingVariants: overlayProps => string = cva(
  "text-4xl sm:text-5xl font-black mb-2",
  {
    "variants": {
      "$type": {
        "lost": "text-[#776e65]",
        "won": "text-[#f9f6f2]",
      },
    },
  },
)

@react.component
let make = (~tiles: array<Game.tile>, ~status: Game.status, ~onRestart: unit => unit) => {
  let isGameOver = status == Game.Lost
  let isWon = status == Game.Won

  let emptyCells = Array.make(~length=16, 0)

  <div
    className="relative w-full max-w-[460px] aspect-square p-2 sm:p-3 rounded-2xl bg-[#bbada0] shadow-xl overflow-hidden"
  >
    /* Static Background Grid Slots */
    <div className="w-full h-full grid grid-cols-4 grid-rows-4">
      {emptyCells
      ->Array.mapWithIndex((_, idx) => {
        <div key={"slot-" ++ Int.toString(idx)} className="w-full h-full p-1.5 sm:p-2">
          <div className="w-full h-full rounded-xl bg-[#cdc1b4]/90" />
        </div>
      })
      ->Utils.renderArray}
    </div>

    /* Dynamic Absolute Animated Tiles Container */
    <div className="absolute inset-2 sm:inset-3 pointer-events-none">
      {tiles
      ->Array.map(t => {
        <Tile key={"tile-" ++ Int.toString(t.id)} tile={t} />
      })
      ->Utils.renderArray}
    </div>

    /* Game Over / Won Overlay */
    {if isGameOver {
      <div className={overlayVariants({"$type": "lost"})}>
        <h2 className={overlayHeadingVariants({"$type": "lost"})}>
          {Utils.renderString("Game Over!")}
        </h2>
        <p className="text-[#8f7a66] font-semibold text-sm mb-6 max-w-xs">
          {Utils.renderString("No more moves left! Try again to beat your best score.")}
        </p>
        <button
          onClick={_ => onRestart()}
          className="px-6 py-3 rounded-xl bg-[#8f7a66] hover:bg-[#7f6a56] text-[#f9f6f2] font-bold text-base shadow-md transition-all active:scale-95 cursor-pointer"
        >
          {Utils.renderString("Try Again")}
        </button>
      </div>
    } else if isWon {
      <div className={overlayVariants({"$type": "won"})}>
        <h2 className={overlayHeadingVariants({"$type": "won"})}>
          {Utils.renderString("You Hit 2048!")}
        </h2>
        <p className="text-[#f9f6f2] font-semibold text-sm mb-6">
          {Utils.renderString("You won! Keep playing to achieve an even higher score.")}
        </p>
        <button
          onClick={_ => onRestart()}
          className="px-6 py-3 rounded-xl bg-[#8f7a66] hover:bg-[#7f6a56] text-[#f9f6f2] font-bold text-base shadow-md transition-all active:scale-95 cursor-pointer"
        >
          {Utils.renderString("Keep Going")}
        </button>
      </div>
    } else {
      React.null
    }}
  </div>
}
