// Game.res - Pure Functional 2048 Engine (Original 2048-Reasons Standard in ReScript v12)

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

type row = list<int>
type grid = list<row>

type position = {
  x: int,
  y: int,
}

type moveResult = {
  direction: direction,
  grid: grid,
  score: int,
  zeroes: int,
}

let emptyGrid: grid = list{list{0, 0, 0, 0}, list{0, 0, 0, 0}, list{0, 0, 0, 0}, list{0, 0, 0, 0}}

let shiftZeroes = (xs: row): row => {
  let nonZeroes = xs->List.filter(x => x != 0)
  let zeroesCount = xs->List.length - nonZeroes->List.length
  let zeroes = List.make(~length=zeroesCount, 0)
  List.concat(zeroes, nonZeroes)
}

let mergeRowRight = (xs: row): row => {
  let rec merge = (index: int, ys: row): row => {
    switch (index, ys) {
    | (0, list{a, b, c, d}) if c == d && c != 0 => merge(1, list{0, a, b, c * 2})
    | (1, list{a, b, c, d}) if b == c && b != 0 => merge(2, list{0, a, b * 2, d})
    | (2, list{a, b, c, d}) if a == b && a != 0 => merge(3, list{0, a * 2, c, d})
    | (0 | 1 | 2, _) => merge(index + 1, ys)
    | _ => ys
    }
  }
  merge(0, xs->shiftZeroes)
}

let mergeRowLeft = (xs: row): row => {
  xs->List.reverse->mergeRowRight->List.reverse
}

let getPosition = (p: position, g: grid): int => {
  switch g->List.get(p.y) {
  | Some(r) =>
    switch r->List.get(p.x) {
    | Some(val) => val
    | None => 0
    }
  | None => 0
  }
}

let getColumns = (g: grid): grid => {
  List.make(~length=4, 0)->List.mapWithIndex((_, x) => {
    List.make(~length=4, 0)->List.mapWithIndex((_, y) => {
      getPosition({x, y}, g)
    })
  })
}

let mergeGridRight = (g: grid): grid => g->List.map(mergeRowRight)
let mergeGridLeft = (g: grid): grid => g->List.map(mergeRowLeft)

let merge = (dir: direction, g: grid): grid => {
  switch dir {
  | Right => mergeGridRight(g)
  | Left => mergeGridLeft(g)
  | Up => g->getColumns->mergeGridLeft->getColumns
  | Down => g->getColumns->mergeGridRight->getColumns
  }
}

let findZeroes = (g: grid): list<position> => {
  let acc = []
  g->List.forEachWithIndex((r, y) => {
    r->List.forEachWithIndex((tile, x) => {
      if tile == 0 {
        let _ = acc->Array.push({x, y})
      }
    })
  })
  acc->List.fromArray
}

let updateRow = (xs: row, targetX: int, newVal: int): row => {
  xs->List.mapWithIndex((val, x) => x == targetX ? newVal : val)
}

let updateGrid = (newVal: int, pos: position, g: grid): grid => {
  g->List.mapWithIndex((r, y) => {
    if y == pos.y {
      updateRow(r, pos.x, newVal)
    } else {
      r
    }
  })
}

let fillRandomEmptyTile = (g: grid): option<grid> => {
  let emptyPositions = findZeroes(g)
  let count = emptyPositions->List.length

  if count == 0 {
    None
  } else {
    let randomIndex = Math.Int.random(0, count)
    let selectedPos = emptyPositions->List.get(randomIndex)

    switch selectedPos {
    | Some(pos) =>
      let newValue = Math.random() < 0.9 ? 2 : 4
      Some(updateGrid(newValue, pos, g))
    | None => None
    }
  }
}

let getScore = (g: grid): int => {
  g->List.reduce(0, (acc, r) => {
    acc + r->List.reduce(0, (rAcc, tile) => rAcc + tile)
  })
}

let getMaxTile = (g: grid): int => {
  g->List.reduce(0, (acc, r) => {
    let rowMax = r->List.reduce(0, (m, tile) => Math.Int.max(m, tile))
    Math.Int.max(acc, rowMax)
  })
}

let gridEqual = (g1: grid, g2: grid): bool => {
  let arr1 = g1->List.toArray->Array.map(List.toArray)
  let arr2 = g2->List.toArray->Array.map(List.toArray)

  arr1->Array.everyWithIndex((r, y) => {
    r->Array.everyWithIndex((val, x) => {
      switch arr2->Array.get(y) {
      | Some(r2) =>
        switch r2->Array.get(x) {
        | Some(val2) => val == val2
        | None => false
        }
      | None => false
      }
    })
  })
}

let getValidMoves = (g: grid): list<moveResult> => {
  list{Right, Up, Down, Left}
  ->List.map(dir => {
    let newGrid = merge(dir, g)
    let zeroes = findZeroes(newGrid)->List.length
    let score = getScore(newGrid)
    {direction: dir, grid: newGrid, score, zeroes}
  })
  ->List.filter(move => !gridEqual(move.grid, g))
}

let bestMove = (g: grid): option<direction> => {
  let validMoves = getValidMoves(g)->List.toArray
  if validMoves->Array.length == 0 {
    None
  } else {
    let sorted = validMoves->Array.copy
    sorted->Array.sort((a, b) => {
      let scoreDiff = b.score - a.score
      if scoreDiff != 0 {
        Int.toFloat(scoreDiff)
      } else {
        Int.toFloat(b.zeroes - a.zeroes)
      }
    })

    switch sorted->Array.get(0) {
    | Some(move) => Some(move.direction)
    | None => None
    }
  }
}

let isMergeable = (g: grid): bool => {
  getValidMoves(g)->List.length > 0
}
