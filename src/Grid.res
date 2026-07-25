// Grid.res - 4x4 Grid Component in ReScript v12 (Original 2048-Reasons Standard)

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

let renderTiles = (row: Game.row, y: int) => {
  row
  ->List.mapWithIndex((tile, x) => {
    let colorClass = getTileColorClass(tile)
    let fontSizeClass = getFontSizeClass(tile)

    <div
      key={"tile-" ++ Int.toString(y) ++ "-" ++ Int.toString(x)}
      className="w-full h-full p-1.5 sm:p-2"
    >
      <div
        className={"w-full h-full rounded-xl flex items-center justify-center font-bold transition-all duration-150 ease-out " ++
        colorClass}
      >
        {if tile > 0 {
          <span className={"font-sans tracking-tight " ++ fontSizeClass}> {React.int(tile)} </span>
        } else {
          React.null
        }}
      </div>
    </div>
  })
  ->Utils.renderList
}

let renderRows = (data: Game.grid) => {
  data
  ->List.mapWithIndex((row, y) => {
    <div key={"row-" ++ Int.toString(y)} className="grid grid-cols-4 w-full h-1/4">
      {renderTiles(row, y)}
    </div>
  })
  ->Utils.renderList
}

@react.component
let make = (~data: Game.grid, ~status: Game.status, ~onRestart: unit => unit) => {
  let isGameOver = status == Game.Lost
  let isWon = status == Game.Won

  <div
    className="relative w-full max-w-[460px] aspect-square p-2 sm:p-3 rounded-2xl bg-[#bbada0] shadow-xl overflow-hidden"
  >
    /* 4x4 Grid Rows */
    <div className="w-full h-full flex flex-col"> {renderRows(data)} </div>

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
