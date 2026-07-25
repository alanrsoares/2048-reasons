// Grid.res - 4x4 Game Board Container with Animated Tile Sliding in ReScript v12

let getTileColorClass = (val: int): string => {
  switch val {
  | 2 => "tile-2"
  | 4 => "tile-4"
  | 8 => "tile-8"
  | 16 => "tile-16"
  | 32 => "tile-32"
  | 64 => "tile-64"
  | 128 => "tile-128"
  | 256 => "tile-256"
  | 512 => "tile-512"
  | 1024 => "tile-1024"
  | 2048 => "tile-2048"
  | _ =>
    if val > 2048 {
      "tile-super"
    } else {
      "bg-[#cdc1b4]/90"
    }
  }
}

let getFontSizeClass = (val: int): string => {
  if val >= 10000 {
    "text-lg sm:text-xl font-bold"
  } else if val >= 1000 {
    "text-2xl sm:text-3xl font-extrabold"
  } else if val >= 100 {
    "text-3xl sm:text-4xl font-extrabold"
  } else {
    "text-4xl sm:text-5xl font-extrabold"
  }
}

type activeTile = {
  key: string,
  val: int,
  x: int,
  y: int,
}

let extractActiveTiles = (data: Game.grid): array<activeTile> => {
  let tiles = []
  data->List.forEachWithIndex((row, y) => {
    row->List.forEachWithIndex((val, x) => {
      if val > 0 {
        let key = "tile-slot-" ++ Int.toString(y) ++ "-" ++ Int.toString(x)
        let _ = tiles->Array.push({key, val, x, y})
      }
    })
  })
  tiles
}

@react.component
let make = (~data: Game.grid, ~status: Game.status, ~onRestart: unit => unit) => {
  let isGameOver = status == Game.Lost
  let isWon = status == Game.Won
  let emptyCells = Array.make(~length=16, 0)
  let activeTiles = extractActiveTiles(data)

  <div
    className="relative w-full max-w-[460px] aspect-square p-2 sm:p-3 rounded-2xl bg-[#bbada0] shadow-xl overflow-hidden"
  >
    /* Static Background 4x4 Grid Slots */
    <div className="w-full h-full grid grid-cols-4 grid-rows-4">
      {emptyCells
      ->Array.mapWithIndex((_, idx) => {
        <div key={"slot-" ++ Int.toString(idx)} className="w-full h-full p-1.5 sm:p-2">
          <div className="w-full h-full rounded-xl bg-[#cdc1b4]/90" />
        </div>
      })
      ->Utils.renderArray}
    </div>

    /* Dynamic Absolute Animated Tiles Container with Smooth Sliding Transitions */
    <div className="absolute inset-2 sm:inset-3 pointer-events-none">
      {activeTiles
      ->Array.map(t => {
        let colorClass = getTileColorClass(t.val)
        let fontSizeClass = getFontSizeClass(t.val)
        let topStyle = Int.toString(t.y * 25) ++ "%"
        let leftStyle = Int.toString(t.x * 25) ++ "%"
        let styleObj = ReactDOMStyle._dictToStyle(
          dict{
            "top": topStyle,
            "left": leftStyle,
          },
        )

        <div
          key={t.key}
          style={styleObj}
          className="absolute w-1/4 h-1/4 p-1.5 sm:p-2 transition-all duration-150 ease-out select-none"
        >
          <div
            className={"w-full h-full rounded-xl flex items-center justify-center font-bold animate-pop-in " ++
            colorClass}
          >
            <span className={"font-sans tracking-tight " ++ fontSizeClass}>
              {React.int(t.val)}
            </span>
          </div>
        </div>
      })
      ->Utils.renderArray}
    </div>

    /* Game Over / Won Overlay */
    {if isGameOver {
      <div
        className="absolute inset-0 rounded-2xl bg-[#faf8ef]/85 backdrop-blur-sm flex flex-col items-center justify-center p-6 text-center animate-pop-in z-30 pointer-events-auto"
      >
        <h2 className="text-4xl sm:text-5xl font-black text-[#776e65] mb-2">
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
      <div
        className="absolute inset-0 rounded-2xl bg-[#edc22e]/85 backdrop-blur-sm flex flex-col items-center justify-center p-6 text-center animate-pop-in z-30 pointer-events-auto"
      >
        <h2 className="text-4xl sm:text-5xl font-black text-[#f9f6f2] mb-2">
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
