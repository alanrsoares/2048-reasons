// Game.res - Smooth Animated 2048 Core Engine in ReScript v12

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

type gridMatrix = array<array<int>>

type moveResult = {
  tiles: array<tile>,
  scoreGained: int,
  moved: bool,
  nextId: int,
}

let emptyMatrix = (): gridMatrix => [
  [0, 0, 0, 0],
  [0, 0, 0, 0],
  [0, 0, 0, 0],
  [0, 0, 0, 0],
]

let tilesToMatrix = (tiles: array<tile>): gridMatrix => {
  let m = emptyMatrix()
  tiles->Array.forEach(t => {
    switch m->Array.get(t.row) {
    | Some(r) => Array.setUnsafe(r, t.col, t.val)
    | None => ()
    }
  })
  m
}

let getEmptyPositions = (tiles: array<tile>): array<(int, int)> => {
  let matrix = tilesToMatrix(tiles)
  let empty = []
  matrix->Array.forEachWithIndex((r, row) => {
    r->Array.forEachWithIndex((val, col) => {
      if val == 0 {
        let _ = empty->Array.push((row, col))
      }
    })
  })
  empty
}

let addRandomTile = (tiles: array<tile>, nextId: int): (array<tile>, int) => {
  let empty = getEmptyPositions(tiles)
  if empty->Array.length == 0 {
    (tiles, nextId)
  } else {
    let randomIndex = Math.Int.random(0, empty->Array.length)
    switch empty->Array.get(randomIndex) {
    | Some((row, col)) =>
      let val = Math.random() < 0.9 ? 2 : 4
      let newTile = {
        id: nextId,
        val,
        row,
        col,
        isNew: true,
        isMerged: false,
      }
      (Array.concat(tiles, [newTile]), nextId + 1)
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
  let newTiles = []
  let totalScore = ref(0)
  let anyMoved = ref(false)
  let curId = ref(nextId)

  let isRowMove = dir == Left || dir == Right
  let isReverse = dir == Right || dir == Down

  for index in 0 to 3 {
    let lineTiles = tiles->Array.filter(t => {
      if isRowMove { t.row == index } else { t.col == index }
    })

    if lineTiles->Array.length > 0 {
      let sorted = lineTiles->Array.copy
      sorted->Array.sort((a, b) => {
        let pA = isRowMove ? a.col : a.row
        let pB = isRowMove ? b.col : b.row
        if isReverse { Int.toFloat(pB - pA) } else { Int.toFloat(pA - pB) }
      })

      let targetPos = ref(isReverse ? 3 : 0)
      let step = isReverse ? -1 : 1
      let i = ref(0)
      let len = sorted->Array.length

      while i.contents < len {
        let t1 = Array.getUnsafe(sorted, i.contents)
        let t2Opt = if i.contents + 1 < len { Some(Array.getUnsafe(sorted, i.contents + 1)) } else { None }

        switch t2Opt {
        | Some(t2) if t1.val == t2.val =>
          let newVal = t1.val * 2
          totalScore.contents = totalScore.contents + newVal
          anyMoved.contents = true

          let mergedTile = {
            id: curId.contents,
            val: newVal,
            row: if isRowMove { index } else { targetPos.contents },
            col: if isRowMove { targetPos.contents } else { index },
            isNew: false,
            isMerged: true,
          }
          curId.contents = curId.contents + 1
          let _ = newTiles->Array.push(mergedTile)
          targetPos.contents = targetPos.contents + step
          i.contents = i.contents + 2

        | _ =>
          let curPos = isRowMove ? t1.col : t1.row
          if curPos != targetPos.contents {
            anyMoved.contents = true
          }
          let movedTile = {
            id: t1.id,
            val: t1.val,
            row: if isRowMove { index } else { targetPos.contents },
            col: if isRowMove { targetPos.contents } else { index },
            isNew: false,
            isMerged: false,
          }
          let _ = newTiles->Array.push(movedTile)
          targetPos.contents = targetPos.contents + step
          i.contents = i.contents + 1
        }
      }
    }
  }

  {
    tiles: newTiles,
    scoreGained: totalScore.contents,
    moved: anyMoved.contents,
    nextId: curId.contents,
  }
}

let getScore = (tiles: array<tile>): int => {
  tiles->Array.reduce(0, (acc, t) => acc + t.val)
}

let getMaxTile = (tiles: array<tile>): int => {
  tiles->Array.reduce(0, (acc, t) => Math.Int.max(acc, t.val))
}

let isMergeable = (tiles: array<tile>): bool => {
  if tiles->Array.length < 16 {
    true
  } else {
    let resL = moveGrid(tiles, Left, 99999)
    let resR = moveGrid(tiles, Right, 99999)
    let resU = moveGrid(tiles, Up, 99999)
    let resD = moveGrid(tiles, Down, 99999)
    resL.moved || resR.moved || resU.moved || resD.moved
  }
}

let bestMove = (tiles: array<tile>): option<direction> => {
  let moves = [Left, Right, Up, Down]
  let validMoves = moves
    ->Array.map(dir => {
      let res = moveGrid(tiles, dir, 99999)
      let emptyCount = getEmptyPositions(res.tiles)->Array.length
      (dir, res.moved, res.scoreGained, emptyCount)
    })
    ->Array.filter(((_, moved, _, _)) => moved)

  if validMoves->Array.length == 0 {
    None
  } else {
    let sorted = validMoves->Array.copy
    sorted->Array.sort(((_, _, scoreA, emptyA), (_, _, scoreB, emptyB)) => {
      let scoreDiff = scoreB - scoreA
      if scoreDiff != 0 {
        Int.toFloat(scoreDiff)
      } else {
        Int.toFloat(emptyB - emptyA)
      }
    })

    switch sorted->Array.get(0) {
    | Some((dir, _, _, _)) => Some(dir)
    | None => None
    }
  }
}
