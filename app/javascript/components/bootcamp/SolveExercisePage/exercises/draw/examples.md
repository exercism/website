## Draw 101 rects

```
let coords = 0
rect(coords,coords,20,20)

repeat(100){
coords = coords + 1
rect(coords,coords,20,20)
}
```

## animate the same rect

```
let coords = 0

repeat(100){
coords = coords + 1
rect(coords,coords,20,20)
redraw()
}
```

## draw 2 rects at the same time

```
let coords = 0

repeat(100){
coords = coords + 1
rect(coords + 10,coords+10,20,20)
rect(coords,coords,20,20)
redraw()
}
```

## bouncing from corners

```
let coords = 0
let size = 20
let delta = 1

repeat(1000){
  if(coords+size > 100 || coords < 0){
delta = delta * -1
  }

coords = coords + delta
rect(coords,coords,size,size)
redraw()
}
```

## ball moving up and down

```
let radius = 20
let x = 50
let y = 0 + radius
let delta = 1

repeat(1000) {
  if (y + radius > 100 || y - radius < 0) {
    delta = delta * -1
  }
  y = y + delta
  circle(x, y, radius)
  redraw()
}
```

## bounce

```
let x = 20
let y = 20
let vy = 0
let gravity = 0.5
let bounce = 0.9
let ground = 100
let radius = 5

function abs(value) {
  if (value < 0) {
    return -value
  }
  return value
}

while (abs(vy) >= 0.1 || y + radius < ground) {
  vy = vy + gravity
  y = y + vy

  if (y + radius >= ground) {
    y = ground - radius
    vy = vy * -bounce
  }

  circle(x, y, radius)
  redraw()
}
```

## use a move function

```
let r1 = rect(20,20,20,20)
let r2 = rect(30,30,30,30)

move(r1, 100, 20, true)
move(r2, 30, 100, true)
```

## mixing singular and concurrent move

```
let r1 = rect(20,20,20,20)
let r2 = rect(30,30,30,30)
let r3 = rect(40,40,40,40)

move(r1, 100, 20, true)
move(r2, 30, 100)
move(r3, 0, 0)
```

## draw many polygons on top of each other

```
let sides = 3
repeat(30){
  polygon(30,30,30,sides)
  sides = sides + 1
}
```
