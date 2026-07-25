// App.res - Main Application Container in ReScript v12 & React 19

module Dom = {
  type keyboardEvent
  @get external key: keyboardEvent => string = "key"
  @val
  external addEventListener: (string, keyboardEvent => unit) => unit = "window.addEventListener"
  @val
  external removeEventListener: (string, keyboardEvent => unit) => unit =
    "window.removeEventListener"
}

module LocalStorage = {
  @val external getItem: string => Null.t<string> = "localStorage.getItem"
  @val external setItem: (string, string) => unit = "localStorage.setItem"
}

let storageKey = "2048_reasons_best_score"

let getInitialBestScore = (): int => {
  switch LocalStorage.getItem(storageKey)->Null.toOption {
  | Some(valStr) =>
    switch Int.fromString(valStr) {
    | Some(n) => n
    | None => 0
    }
  | None => 0
  }
}

type state = {
  tiles: array<Game.tile>,
  status: Game.status,
  score: int,
  bestScore: int,
  isAutoPlaying: bool,
  nextId: int,
}

type action =
  | Move(Game.direction)
  | StepBot
  | ToggleAutoPlay
  | Reset

let createInitialState = (bestScore: int): state => {
  let (tiles, nextId) = Game.createInitialState()
  {
    tiles,
    status: Game.Playing,
    score: 0,
    bestScore,
    isAutoPlaying: false,
    nextId,
  }
}

let reducer = (state: state, action: action): state => {
  switch action {
  | Reset => createInitialState(state.bestScore)

  | ToggleAutoPlay => {
      ...state,
      isAutoPlaying: !state.isAutoPlaying,
      status: if !state.isAutoPlaying {
        Game.AutoPlaying
      } else {
        Game.Playing
      },
    }

  | Move(dir) =>
    if state.status == Game.Lost {
      state
    } else {
      let res = Game.moveGrid(state.tiles, dir, state.nextId)
      if !res.moved {
        if !Game.isMergeable(state.tiles) {
          {...state, status: Game.Lost, isAutoPlaying: false}
        } else {
          state
        }
      } else {
        let (tilesWithRandom, nextId') = Game.addRandomTile(res.tiles, res.nextId)
        let newScore = state.score + res.scoreGained
        let newBest = Math.Int.max(state.bestScore, newScore)
        if newBest > state.bestScore {
          LocalStorage.setItem(storageKey, Int.toString(newBest))
        }

        let maxTile = Game.getMaxTile(tilesWithRandom)
        let status = if maxTile >= 2048 && state.status != Game.Won {
          Game.Won
        } else if !Game.isMergeable(tilesWithRandom) {
          Game.Lost
        } else {
          state.status
        }

        {
          tiles: tilesWithRandom,
          status,
          score: newScore,
          bestScore: newBest,
          isAutoPlaying: state.isAutoPlaying,
          nextId: nextId',
        }
      }
    }

  | StepBot =>
    if state.status == Game.Lost {
      {...state, isAutoPlaying: false}
    } else {
      switch Game.bestMove(state.tiles) {
      | Some(dir) =>
        let res = Game.moveGrid(state.tiles, dir, state.nextId)
        let (tilesWithRandom, nextId') = Game.addRandomTile(res.tiles, res.nextId)
        let newScore = state.score + res.scoreGained
        let newBest = Math.Int.max(state.bestScore, newScore)
        if newBest > state.bestScore {
          LocalStorage.setItem(storageKey, Int.toString(newBest))
        }

        let maxTile = Game.getMaxTile(tilesWithRandom)
        let status = if maxTile >= 2048 && state.status != Game.Won {
          Game.Won
        } else if !Game.isMergeable(tilesWithRandom) {
          Game.Lost
        } else {
          state.status
        }

        {
          tiles: tilesWithRandom,
          status,
          score: newScore,
          bestScore: newBest,
          isAutoPlaying: state.isAutoPlaying,
          nextId: nextId',
        }
      | None => {...state, status: Game.Lost, isAutoPlaying: false}
      }
    }
  }
}

@react.component
let make = () => {
  let (state, dispatch) = React.useReducer(reducer, createInitialState(getInitialBestScore()))

  /* Keyboard Event Listener Effect */
  React.useEffect0(() => {
    let handleKeyDown = (evt: Dom.keyboardEvent) => {
      let key = Dom.key(evt)
      switch key {
      | "ArrowUp" | "w" | "W" => dispatch(Move(Game.Up))
      | "ArrowDown" | "s" | "S" => dispatch(Move(Game.Down))
      | "ArrowLeft" | "a" | "A" => dispatch(Move(Game.Left))
      | "ArrowRight" | "d" | "D" => dispatch(Move(Game.Right))
      | "r" | "R" => dispatch(Reset)
      | _ => ()
      }
    }

    Dom.addEventListener("keydown", handleKeyDown)
    Some(() => Dom.removeEventListener("keydown", handleKeyDown))
  })

  /* Auto-Play Bot Effect Loop */
  React.useEffect1(() => {
    if state.isAutoPlaying && state.status != Game.Lost {
      let timer = setInterval(() => {
        dispatch(StepBot)
      }, 160)
      Some(() => clearInterval(timer))
    } else {
      None
    }
  }, [state.isAutoPlaying])

  <main
    className="min-h-screen py-8 px-4 flex flex-col items-center justify-between bg-[#faf8ef] text-[#776e65]"
  >
    <div className="w-full max-w-[460px] flex flex-col items-center gap-5 my-auto">
      /* Header Section */
      <header className="w-full flex flex-col gap-4">
        /* Row 1: Title & Score Badges */
        <div className="flex items-start justify-between w-full">
          /* 2048 Title Container with Label Right-Edge Aligned */
          <div className="relative inline-block">
            <h1
              className="text-6xl sm:text-7xl font-black tracking-tight text-[#776e65] leading-none"
            >
              {Utils.renderString("2048")}
            </h1>
            <span
              className="absolute bottom-0 right-0 translate-y-3/4 px-1.5 py-0.5 rounded bg-[#edc22e] text-white font-extrabold text-[9px] sm:text-[10px] tracking-wider uppercase whitespace-nowrap shadow-xs"
            >
              {Utils.renderString("RESCRIPT V12")}
            </span>
          </div>

          <ScoreBoard score={state.score} bestScore={state.bestScore} />
        </div>

        /* Row 2: Tagline & Control Buttons */
        <div className="flex items-center justify-between w-full gap-2">
          <p className="text-xs sm:text-sm font-medium text-[#776e65] leading-tight">
            {Utils.renderString("Join the numbers and get to the ")}
            <strong className="text-[#776e65] font-black">
              {Utils.renderString("2048 tile!")}
            </strong>
          </p>

          <Controls
            isAutoPlaying={state.isAutoPlaying}
            onToggleAutoPlay={() => dispatch(ToggleAutoPlay)}
            onReset={() => dispatch(Reset)}
          />
        </div>
      </header>

      /* Game Grid with Swipe Zone */
      <SwipeZone onSwipe={dir => dispatch(Move(dir))}>
        <Grid tiles={state.tiles} status={state.status} onRestart={() => dispatch(Reset)} />
      </SwipeZone>

      /* Game Instructions & Rules */
      <section
        className="w-full text-xs font-medium text-[#776e65] leading-relaxed bg-[#ede0c8]/60 p-3.5 rounded-md border border-[#d8cbb3]/80"
      >
        <p>
          <strong className="text-[#776e65] font-black">
            {Utils.renderString("HOW TO PLAY: ")}
          </strong>
          {Utils.renderString(
            "Use your arrow keys or swipe to move the tiles. When two tiles with the same number touch, they merge into one!",
          )}
        </p>
      </section>
    </div>

    /* Footer Info */
    <footer
      className="mt-6 text-center text-xs font-semibold text-[#8f7a66] flex flex-col items-center gap-1"
    >
      <p> {Utils.renderString("Rebuilt in ReScript v12, React 19, Vite & Tailwind CSS")} </p>
    </footer>
  </main>
}
