// Game_sim.res - Headless AI Bot Simulation Harness in ReScript v12

open Game

@val external performanceNow: unit => float = "performance.now"

type simResult = {
  finalScore: int,
  maxTile: int,
  totalMoves: int,
  won: bool,
}

let runSingleGame = (): simResult => {
  let (initialTiles, initialNextId) = createInitialState()
  let tiles = ref(initialTiles)
  let nextId = ref(initialNextId)
  let score = ref(0)
  let moves = ref(0)
  let gameOver = ref(false)
  let won = ref(false)

  while !gameOver.contents && moves.contents < 25000 {
    switch bestMove(tiles.contents) {
    | Some(dir) =>
      let res = moveGrid(tiles.contents, dir, nextId.contents)
      if res.moved {
        let (tiles', nextId') = addRandomTile(res.tiles, res.nextId)
        tiles := tiles'
        nextId := nextId'
        score := score.contents + res.scoreGained
        moves := moves.contents + 1

        let maxTile = getMaxTile(tiles.contents)
        if maxTile >= 2048 {
          won := true
        }

        if !isMergeable(tiles.contents) {
          gameOver := true
        }
      } else if !isMergeable(tiles.contents) {
        gameOver := true
      }
    | None => gameOver := true
    }
  }

  {
    finalScore: score.contents,
    maxTile: getMaxTile(tiles.contents),
    totalMoves: moves.contents,
    won: won.contents,
  }
}

let runSimulationBatch = (numGames: int) => {
  Console.log("==================================================")
  Console.log("🎮 2048 ReScript Bot Strategy Simulation Harness")
  Console.log("==================================================")
  Console.log("Running " ++ Int.toString(numGames) ++ " headless game simulations...")

  let startTime = performanceNow()
  let results = []

  for i in 1 to numGames {
    let res = runSingleGame()
    let _ = results->Array.push(res)
    if mod(i, 10) == 0 || i == numGames {
      Console.log(
        " Progress: " ++ Int.toString(i) ++ "/" ++ Int.toString(numGames) ++ " games complete",
      )
    }
  }

  let totalTime = performanceNow() -. startTime

  let winCount = results->Array.filter(r => r.won)->Array.length
  let winRate = Int.toFloat(winCount) /. Int.toFloat(numGames) *. 100.0

  let totalScore = results->Array.reduce(0, (acc, r) => acc + r.finalScore)
  let avgScore = totalScore / numGames

  let maxScore = results->Array.reduce(0, (acc, r) => Math.Int.max(acc, r.finalScore))

  let count2048 = results->Array.filter(r => r.maxTile >= 2048)->Array.length
  let count1024 = results->Array.filter(r => r.maxTile == 1024)->Array.length
  let count512 = results->Array.filter(r => r.maxTile == 512)->Array.length
  let count256OrLess = results->Array.filter(r => r.maxTile <= 256)->Array.length

  Console.log("\n==================================================")
  Console.log("📊 SIMULATION RESULTS (" ++ Int.toString(numGames) ++ " GAMES)")
  Console.log("==================================================")
  Console.log(
    "🏆 Win Rate (2048+ Tile) : " ++
    Float.toFixed(winRate, ~digits=1) ++
    "% (" ++
    Int.toString(winCount) ++
    "/" ++
    Int.toString(numGames) ++ ")",
  )
  Console.log("📈 Average Final Score    : " ++ Int.toString(avgScore))
  Console.log("🔥 Peak High Score       : " ++ Int.toString(maxScore))
  Console.log(
    "⚡ Execution Speed        : " ++
    Float.toFixed(totalTime /. 1000.0, ~digits=2) ++
    "s (" ++
    Float.toFixed(Int.toFloat(numGames) /. (totalTime /. 1000.0), ~digits=1) ++ " games/sec)",
  )

  Console.log("\n🎯 Max Tile Distribution:")
  Console.log(
    "  • 2048+ : " ++
    Int.toString(count2048) ++
    " (" ++
    Float.toFixed(Int.toFloat(count2048) /. Int.toFloat(numGames) *. 100.0, ~digits=1) ++ "%)",
  )
  Console.log(
    "  • 1024  : " ++
    Int.toString(count1024) ++
    " (" ++
    Float.toFixed(Int.toFloat(count1024) /. Int.toFloat(numGames) *. 100.0, ~digits=1) ++ "%)",
  )
  Console.log(
    "  • 512   : " ++
    Int.toString(count512) ++
    " (" ++
    Float.toFixed(Int.toFloat(count512) /. Int.toFloat(numGames) *. 100.0, ~digits=1) ++ "%)",
  )
  Console.log(
    "  • <=256 : " ++
    Int.toString(count256OrLess) ++
    " (" ++
    Float.toFixed(Int.toFloat(count256OrLess) /. Int.toFloat(numGames) *. 100.0, ~digits=1) ++ "%)",
  )
  Console.log("==================================================\n")
}

let main = () => {
  let numGames = 50
  runSimulationBatch(numGames)
}

main()
