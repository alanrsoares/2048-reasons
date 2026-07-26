// Tile.res - Animated 2048 Tile Component using @styled-cva/react in ReScript v12

open StyledCva

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

let tileInnerVariants = cva(
  "w-full h-full rounded-xl flex items-center justify-center font-bold tile-spring-transition",
  {
    "variants": {
      "$anim": {
        "merged": "animate-merge-pulse z-10",
        "new": "animate-pop-in z-0",
        "idle": "z-0",
      },
    },
    "defaultVariants": {
      "$anim": "idle",
    },
  },
)

@react.component
let make = (~tile: Game.tile) => {
  let colorClass = getTileColorClass(tile.val)
  let fontSizeClass = getFontSizeClass(tile.val)

  let animState = if tile.isMerged {
    "merged"
  } else if tile.isNew {
    "new"
  } else {
    "idle"
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
    className="absolute w-1/4 h-1/4 p-1.5 sm:p-2 tile-spring-transition select-none"
  >
    <div className={cn([tileInnerVariants({"$anim": animState}), colorClass])}>
      <span className={"font-sans tracking-tight " ++ fontSizeClass}> {React.int(tile.val)} </span>
    </div>
  </div>
}
