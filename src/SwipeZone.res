// SwipeZone.res - Touch Gesture Handler in ReScript v12

type touchState = {
  startX: float,
  startY: float,
}

type touchItem = {
  clientX: int,
  clientY: int,
}

module TouchEvent = {
  type t = ReactEvent.Touch.t
  @get external touches: t => array<touchItem> = "touches"
  @get external changedTouches: t => array<touchItem> = "changedTouches"
}

@react.component
let make = (~onSwipe: Game.direction => unit, ~children: React.element) => {
  let touchRef = React.useRef(None)

  let handleTouchStart = (evt: ReactEvent.Touch.t) => {
    let touches = TouchEvent.touches(evt)
    switch touches->Array.get(0) {
    | Some(t) =>
      let clientX = Int.toFloat(t.clientX)
      let clientY = Int.toFloat(t.clientY)
      touchRef.current = Some({startX: clientX, startY: clientY})
    | None => ()
    }
  }

  let handleTouchEnd = (evt: ReactEvent.Touch.t) => {
    let changed = TouchEvent.changedTouches(evt)
    switch (touchRef.current, changed->Array.get(0)) {
    | (Some(start), Some(t)) =>
      let endX = Int.toFloat(t.clientX)
      let endY = Int.toFloat(t.clientY)
      let diffX = endX -. start.startX
      let diffY = endY -. start.startY
      let threshold = 30.0

      let absX = Math.abs(diffX)
      let absY = Math.abs(diffY)

      if Math.max(absX, absY) > threshold {
        if absX > absY {
          if diffX > 0.0 {
            onSwipe(Game.Right)
          } else {
            onSwipe(Game.Left)
          }
        } else {
          if diffY > 0.0 {
            onSwipe(Game.Down)
          } else {
            onSwipe(Game.Up)
          }
        }
      }
      touchRef.current = None
    | _ => ()
    }
  }

  <div
    onTouchStart={handleTouchStart}
    onTouchEnd={handleTouchEnd}
    className="touch-none w-full flex justify-center"
  >
    children
  </div>
}
