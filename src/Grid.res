// Grid.res - Classic 2048 Grid Board Container in ReScript v12

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
      ->React.array}
    </div>

    /* Dynamic Absolute Animated Tiles Container */
    <div className="absolute inset-2 sm:inset-3 pointer-events-none">
      {tiles
      ->Array.map(t => {
        <Tile key={"tile-" ++ Int.toString(t.id)} tile={t} />
      })
      ->React.array}
    </div>

    /* Game Over Overlay */
    {if isGameOver {
      <div
        className="absolute inset-0 rounded-2xl bg-[#faf8ef]/85 backdrop-blur-sm flex flex-col items-center justify-center p-6 text-center animate-pop-in z-30 pointer-events-auto"
      >
        <h2 className="text-4xl sm:text-5xl font-black text-[#776e65] mb-2">
          {React.string("Game Over!")}
        </h2>
        <p className="text-[#8f7a66] font-semibold text-sm mb-6 max-w-xs">
          {React.string("No more moves left! Try again to beat your best score.")}
        </p>
        <button
          onClick={_ => onRestart()}
          className="px-6 py-3 rounded-xl bg-[#8f7a66] hover:bg-[#7f6a56] text-[#f9f6f2] font-bold text-base shadow-md transition-all active:scale-95 cursor-pointer"
        >
          {React.string("Try Again")}
        </button>
      </div>
    } else if isWon {
      <div
        className="absolute inset-0 rounded-2xl bg-[#edc22e]/85 backdrop-blur-sm flex flex-col items-center justify-center p-6 text-center animate-pop-in z-30 pointer-events-auto"
      >
        <h2 className="text-4xl sm:text-5xl font-black text-[#f9f6f2] mb-2">
          {React.string("You Hit 2048!")}
        </h2>
        <p className="text-[#f9f6f2] font-semibold text-sm mb-6">
          {React.string("You won! Keep playing to achieve an even higher score.")}
        </p>
        <button
          onClick={_ => onRestart()}
          className="px-6 py-3 rounded-xl bg-[#8f7a66] hover:bg-[#7f6a56] text-[#f9f6f2] font-bold text-base shadow-md transition-all active:scale-95 cursor-pointer"
        >
          {React.string("Keep Going")}
        </button>
      </div>
    } else {
      React.null
    }}
  </div>
}
