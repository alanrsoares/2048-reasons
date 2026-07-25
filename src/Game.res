// Game.res - 2048 Core Engine with Persistent Tile Transitions in ReScript v12

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

let bestMove = (tiles: array<tile>): option<direction> => {
  let directions = [Right, Up, Down, Left]
  let validMoves = []

  directions->Array.forEach(dir => {
    let res = moveGrid(tiles, dir, 999999)
    if res.moved {
      let emptyCount = findEmptySlots(res.tiles)->Array.length
      let _ = validMoves->Array.push((dir, res.scoreGained, emptyCount))
    }
  })

  if validMoves->Array.length == 0 {
    None
  } else {
    validMoves->Array.sort((a, b) => {
      let (_, scoreA, emptyA) = a
      let (_, scoreB, emptyB) = b
      let scoreDiff = scoreB - scoreA
      if scoreDiff != 0 {
        Int.toFloat(scoreDiff)
      } else {
        Int.toFloat(emptyB - emptyA)
      }
    })

    switch validMoves[0] {
    | Some((dir, _, _)) => Some(dir)
    | None => None
    }
  }
}
