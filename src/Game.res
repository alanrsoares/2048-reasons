// Game.res - 2048 Core Engine with 2-Step Lookahead Expectimax Solver Strategy in ReScript v12

type status =
  | New
  | Playing
  | AutoPlaying
  | Lost
  | Won

type direction =
  | Left
  | Right
  | Up
  | Down

type tile = {
  id: int,
  val: int,
  row: int,
  col: int,
  isNew: bool,
  isMerged: bool,
}

type moveResult = {
  tiles: array<tile>,
  moved: bool,
  scoreGained: int,
  nextId: int,
}

let tilesToMatrix = (tiles: array<tile>): array<array<int>> => {
  let matrix = Array.make(~length=4, 0)->Array.map(_ => Array.make(~length=4, 0))
  tiles->Array.forEach(t => {
    switch matrix[t.row] {
    | Some(r) => r[t.col] = t.val
    | None => ()
    }
  })
  matrix
}

let findEmptySlots = (tiles: array<tile>): array<(int, int)> => {
  let matrix = tilesToMatrix(tiles)
  let empty = []
  for r in 0 to 3 {
    for c in 0 to 3 {
      switch matrix[r] {
      | Some(row) =>
        switch row[c] {
        | Some(val) =>
          if val == 0 {
            let _ = empty->Array.push((r, c))
          }
        | None => ()
        }
      | None => ()
      }
    }
  }
  empty
}

let addRandomTile = (tiles: array<tile>, nextId: int): (array<tile>, int) => {
  let empty = findEmptySlots(tiles)
  if empty->Array.length == 0 {
    (tiles, nextId)
  } else {
    let randomIndex = Math.Int.random(0, empty->Array.length)
    switch empty[randomIndex] {
    | Some((r, c)) =>
      let newVal = Math.random() < 0.9 ? 2 : 4
      let newTile = {
        id: nextId,
        val: newVal,
        row: r,
        col: c,
        isNew: true,
        isMerged: false,
      }
      let updated = tiles->Array.concat([newTile])
      (updated, nextId + 1)
    | None => (tiles, nextId)
    }
  }
}

let createInitialState = (): (array<tile>, int) => {
  let (t1, id1) = addRandomTile([], 1)
  let (t2, id2) = addRandomTile(t1, id1)
  (t2, id2)
}

let moveGrid = (tiles: array<tile>, dir: direction, nextId: int): moveResult => {
  let moved = ref(false)
  let scoreGained = ref(0)
  let curNextId = ref(nextId)
  let resultTiles = []

  let isRowMove = dir == Left || dir == Right
  let isReverse = dir == Right || dir == Down

  for index in 0 to 3 {
    let lineTiles = tiles->Array.filter(t => {
      if isRowMove {
        t.row == index
      } else {
        t.col == index
      }
    })

    // Sort tiles in direction of movement
    lineTiles->Array.sort((a, b) => {
      let posA = isRowMove ? a.col : a.row
      let posB = isRowMove ? b.col : b.row
      if isReverse {
        Int.toFloat(posB - posA)
      } else {
        Int.toFloat(posA - posB)
      }
    })

    let targetPos = ref(isReverse ? 3 : 0)
    let step = isReverse ? -1 : 1
    let i = ref(0)
    let len = lineTiles->Array.length

    while i.contents < len {
      switch lineTiles[i.contents] {
      | Some(t1) =>
        let hasNext = i.contents + 1 < len
        let merged = ref(false)

        if hasNext {
          switch lineTiles[i.contents + 1] {
          | Some(t2) =>
            if t1.val == t2.val {
              let mergedVal = t1.val * 2
              scoreGained := scoreGained.contents + mergedVal
              let targetR = isRowMove ? index : targetPos.contents
              let targetC = isRowMove ? targetPos.contents : index

              let newTile = {
                id: curNextId.contents,
                val: mergedVal,
                row: targetR,
                col: targetC,
                isNew: false,
                isMerged: true,
              }
              curNextId := curNextId.contents + 1
              let _ = resultTiles->Array.push(newTile)
              moved := true
              merged := true
              i := i.contents + 2
            }
          | None => ()
          }
        }

        if !merged.contents {
          let targetR = isRowMove ? index : targetPos.contents
          let targetC = isRowMove ? targetPos.contents : index

          if t1.row != targetR || t1.col != targetC || t1.isNew || t1.isMerged {
            moved := true
          }

          let updatedTile = {
            ...t1,
            row: targetR,
            col: targetC,
            isNew: false,
            isMerged: false,
          }
          let _ = resultTiles->Array.push(updatedTile)
          i := i.contents + 1
        }

        targetPos := targetPos.contents + step
      | None => i := i.contents + 1
      }
    }
  }

  {
    tiles: resultTiles,
    moved: moved.contents,
    scoreGained: scoreGained.contents,
    nextId: curNextId.contents,
  }
}

let getScore = (tiles: array<tile>): int => {
  tiles->Array.reduce(0, (acc, t) => acc + t.val)
}

let getMaxTile = (tiles: array<tile>): int => {
  tiles->Array.reduce(0, (m, t) => Math.Int.max(m, t.val))
}

let isMergeable = (tiles: array<tile>): bool => {
  if tiles->Array.length < 16 {
    true
  } else {
    let directions = [Left, Right, Up, Down]
    directions->Array.some(dir => {
      let res = moveGrid(tiles, dir, 999999)
      res.moved
    })
  }
}

/* Snake Weight Matrix anchoring max values at top-left [0, 0] */
let snakeWeightMatrix = [
  [65536.0, 32768.0, 16384.0, 8192.0],
  [512.0, 1024.0, 2048.0, 4096.0],
  [256.0, 128.0, 64.0, 32.0],
  [2.0, 4.0, 8.0, 16.0],
]

let evaluateGrid = (tiles: array<tile>): float => {
  let matrix = tilesToMatrix(tiles)
  let score = ref(0.0)
  let emptyCount = findEmptySlots(tiles)->Array.length

  for r in 0 to 3 {
    for c in 0 to 3 {
      switch matrix[r] {
      | Some(row) =>
        switch row[c] {
        | Some(val) =>
          if val > 0 {
            switch snakeWeightMatrix[r] {
            | Some(wRow) =>
              switch wRow[c] {
              | Some(w) => score := score.contents +. Int.toFloat(val) *. w
              | None => ()
              }
            | None => ()
            }
          }
        | None => ()
        }
      | None => ()
      }
    }
  }

  let emptyBonus = Int.toFloat(emptyCount * emptyCount) *. 5000.0
  score.contents +. emptyBonus
}

/* 2-Step Lookahead Expectimax Solver Strategy */
let bestMove = (tiles: array<tile>): option<direction> => {
  let directions = [Up, Left, Right, Down]
  let bestDir = ref(None)
  let maxEval = ref(-1.0)

  directions->Array.forEach(dir1 => {
    let res1 = moveGrid(tiles, dir1, 999999)
    if res1.moved {
      let eval1 = evaluateGrid(res1.tiles) +. Int.toFloat(res1.scoreGained) *. 10000.0

      let maxStep2 = ref(eval1)
      directions->Array.forEach(dir2 => {
        let res2 = moveGrid(res1.tiles, dir2, 999999)
        if res2.moved {
          let eval2 = evaluateGrid(res2.tiles) +. Int.toFloat(res2.scoreGained) *. 10000.0
          if eval2 > maxStep2.contents {
            maxStep2 := eval2
          }
        }
      })

      if maxStep2.contents > maxEval.contents {
        maxEval := maxStep2.contents
        bestDir := Some(dir1)
      }
    }
  })

  bestDir.contents
}
