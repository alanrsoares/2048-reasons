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

    /* Footer Info - Pipe Split with ReScript & GitHub Logos */
    <footer
      className="mt-6 text-center text-xs font-bold text-[#8f7a66] flex items-center justify-center gap-3"
    >
      <a
        href="https://rescript-lang.org"
        target="_blank"
        rel="noopener noreferrer"
        className="flex items-center gap-1.5 hover:text-[#776e65] transition-colors"
      >
        <svg className="w-4 h-4 text-[#e6484f]" viewBox="0 0 24 24" fill="currentColor">
          <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5" />
        </svg>
        <span> {Utils.renderString("ReScript v12")} </span>
      </a>

      <span className="text-[#d8cbb3] font-normal"> {Utils.renderString("|")} </span>

      <a
        href="https://github.com/alanrsoares/2048-reasons"
        target="_blank"
        rel="noopener noreferrer"
        className="flex items-center gap-1.5 hover:text-[#776e65] transition-colors"
      >
        <svg className="w-4 h-4 fill-current" viewBox="0 0 24 24">
          <path
            fillRule="evenodd"
            clipRule="evenodd"
            d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.53 1.032 1.53 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"
          />
        </svg>
        <span> {Utils.renderString("GitHub")} </span>
      </a>
    </footer>
  </main>
}
