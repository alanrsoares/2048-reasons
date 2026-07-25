// Tile.res - Animated 2048 Tile Component in ReScript v12

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

@react.component
let make = (~tile: Game.tile) => {
  let colorClass = getTileColorClass(tile.val)
  let fontSizeClass = getFontSizeClass(tile.val)

  let animationClass = if tile.isMerged {
    "animate-merge-pulse z-10"
  } else if tile.isNew {
    "animate-pop-in z-0"
  } else {
    "z-0"
  }

  let topStyle = Int.toString(tile.row * 25) ++ "%"
  let leftStyle = Int.toString(tile.col * 25) ++ "%"

  let styleObj = ReactDOMStyle._dictToStyle(
    dict{
      "top": topStyle,
      "left": leftStyle,
    },
  )

  <div
    style={styleObj}
    className="absolute w-1/4 h-1/4 p-1.5 sm:p-2 transition-all duration-150 ease-out select-none"
  >
    <div
      className={"w-full h-full rounded-xl flex items-center justify-center font-bold transition-all duration-150 ease-out " ++
      colorClass ++
      " " ++
      animationClass}
    >
      <span className={"font-sans tracking-tight " ++ fontSizeClass}> {React.int(tile.val)} </span>
    </div>
  </div>
}
