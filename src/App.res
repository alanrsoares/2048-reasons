// App.res - Main Application Container in ReScript v12 & React 19 using @styled-cva/react Tw

open StyledCva

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
  if %raw("typeof window !== 'undefined' && typeof localStorage !== 'undefined'") {
    switch LocalStorage.getItem(storageKey)->Null.toOption {
    | Some(valStr) =>
      switch Int.fromString(valStr) {
      | Some(n) => n
      | None => 0
      }
    | None => 0
    }
  } else {
    0
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
        if (
          newBest > state.bestScore &&
            %raw("typeof window !== 'undefined' && typeof localStorage !== 'undefined'")
        ) {
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
        if (
          newBest > state.bestScore &&
            %raw("typeof window !== 'undefined' && typeof localStorage !== 'undefined'")
        ) {
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

module MainShell = {
  let make = Tw.main(
    "min-h-screen py-8 px-4 flex flex-col items-center justify-between bg-[#faf8ef] text-[#776e65]",
  )
}

module HeaderBox = {
  let make = Tw.header("w-full flex flex-col gap-4")
}

module InstructionBox = {
  let make = Tw.section(
    "w-full text-xs font-medium text-[#776e65] leading-relaxed bg-[#ede0c8]/60 p-3.5 rounded-md border border-[#d8cbb3]/80",
  )
}

module FooterBox = {
  let make = Tw.footer(
    "mt-6 text-center text-xs font-bold text-[#8f7a66] flex items-center justify-center gap-3",
  )
}

module LinkAnchor = {
  let make = Tw.a("flex items-center gap-1.5 hover:text-[#776e65] transition-colors")
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

  <MainShell>
    <div className="w-full max-w-115 flex flex-col items-center gap-5 my-auto">
      /* Header Section */
      <HeaderBox>
        /* Row 1: Title & Score Badges */
        <div className="flex items-center justify-between w-full">
          /* 2048 Title with Inline ReScript Brandmark Logo */
          <h1
            className="text-5xl sm:text-6xl font-black tracking-tight text-[#776e65] leading-none flex items-center gap-2 sm:gap-2.5"
          >
            <svg
              className="w-9 h-9 sm:w-11 sm:h-11 rounded-xl shadow-xs shrink-0"
              viewBox="0 0 250 250"
              fill="none"
            >
              <path
                fill="#E84F4F"
                d="M0 80.086C0 46.72 0 30.044 8.496 18.342a44.557 44.557 0 0 1 9.846-9.847C30.032 0 46.719 0 80.082 0h89.83c33.368 0 50.042 0 61.745 8.495a44.452 44.452 0 0 1 9.841 9.847c8.5 11.695 8.5 28.377 8.5 61.744v89.828c0 33.367 0 50.042-8.5 61.744a44.32 44.32 0 0 1-9.841 9.841C219.961 250 203.28 250 169.912 250h-89.83c-33.363 0-50.043 0-61.74-8.501a44.428 44.428 0 0 1-9.846-9.841C0 219.963 0 203.281 0 169.914V80.086Z"
              />
              <path
                fill="#fff"
                d="M169.41 121.016c16.393 0 29.683-13.29 29.683-29.683s-13.29-29.682-29.683-29.682-29.682 13.29-29.682 29.683Z"
              />
              <path
                fill="#fff"
                d="M65.318 87.582c0-9.422 0-14.135 1.84-17.74a16.802 16.802 0 0 1 7.355-7.364c3.6-1.831 8.313-1.831 17.74-1.831h23.564v109.398c0 7.842 0 11.765-1.282 14.854a16.823 16.823 0 0 1-9.11 9.108c-3.091 1.282-7.014 1.282-14.853 1.282-7.842 0-11.765 0-14.854-1.282a16.817 16.817 0 0 1-9.11-9.108c-1.282-3.091-1.282-7.014-1.282-14.854l-.008-82.463Z"
              />
            </svg>
            <span> {Utils.renderString("2048")} </span>
          </h1>

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
      </HeaderBox>

      /* Game Grid with Swipe Zone */
      <SwipeZone onSwipe={dir => dispatch(Move(dir))}>
        <Grid tiles={state.tiles} status={state.status} onRestart={() => dispatch(Reset)} />
      </SwipeZone>

      /* Game Instructions & Rules */
      <InstructionBox>
        <p>
          <strong className="text-[#776e65] font-black">
            {Utils.renderString("HOW TO PLAY: ")}
          </strong>
          {Utils.renderString(
            "Use your arrow keys or swipe to move the tiles. When two tiles with the same number touch, they merge into one!",
          )}
        </p>
      </InstructionBox>
    </div>
    <FooterBox>
      <LinkAnchor href="https://rescript-lang.org" target="_blank" rel="noopener noreferrer">
        <svg className="w-4 h-4 rounded-xs shadow-2xs" viewBox="0 0 250 250" fill="none">
          <path
            fill="#E84F4F"
            d="M0 80.086C0 46.72 0 30.044 8.496 18.342a44.557 44.557 0 0 1 9.846-9.847C30.032 0 46.719 0 80.082 0h89.83c33.368 0 50.042 0 61.745 8.495a44.452 44.452 0 0 1 9.841 9.847c8.5 11.695 8.5 28.377 8.5 61.744v89.828c0 33.367 0 50.042-8.5 61.744a44.32 44.32 0 0 1-9.841 9.841C219.961 250 203.28 250 169.912 250h-89.83c-33.363 0-50.043 0-61.74-8.501a44.428 44.428 0 0 1-9.846-9.841C0 219.963 0 203.281 0 169.914V80.086Z"
          />
          <path
            fill="#fff"
            d="M169.41 121.016c16.393 0 29.683-13.29 29.683-29.683s-13.29-29.682-29.683-29.682-29.682 13.29-29.682 29.683Z"
          />
          <path
            fill="#fff"
            d="M65.318 87.582c0-9.422 0-14.135 1.84-17.74a16.802 16.802 0 0 1 7.355-7.364c3.6-1.831 8.313-1.831 17.74-1.831h23.564v109.398c0 7.842 0 11.765-1.282 14.854a16.823 16.823 0 0 1-9.11 9.108c-3.091 1.282-7.014 1.282-14.853 1.282-7.842 0-11.765 0-14.854-1.282a16.817 16.817 0 0 1-9.11-9.108c-1.282-3.091-1.282-7.014-1.282-14.854l-.008-82.463Z"
          />
        </svg>
        <span> {Utils.renderString("ReScript v12")} </span>
      </LinkAnchor>
      <span className="text-[#d8cbb3] font-normal"> {Utils.renderString("|")} </span>
      <LinkAnchor
        href="https://github.com/alanrsoares/2048-reasons" target="_blank" rel="noopener noreferrer"
      >
        <svg className="w-4 h-4 fill-current" viewBox="0 0 24 24">
          <path
            fillRule="evenodd"
            clipRule="evenodd"
            d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.53 1.032 1.53 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"
          />
        </svg>
        <span> {Utils.renderString("GitHub")} </span>
      </LinkAnchor>
    </FooterBox>
  </MainShell>
}
