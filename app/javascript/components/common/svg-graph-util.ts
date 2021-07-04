export type DataPoint = {
  x: number
  y: number
}

export type Line = {
  length: number
  angle: number
}

const SMOOTHING_RATIO = 0.2

export const minMaxNormalize = (data: Array<number>): Array<number> => {
  const min = Math.min(0, ...data)
  const max = Math.max(...data)
  return data.map((n) => (n - min) / (max - min))
}

export const drawSegmentPath = (dataPoints: Array<DataPoint>): string => {
  return dataPoints.reduce(
    (
      path: string,
      dataPoint: DataPoint,
      idx: number,
      dataPoints: Array<DataPoint>
    ) => {
      switch (idx) {
        case 0:
          return `${drawM(dataPoint)}`
        case 1:
          return `${path} ${drawC(dataPoints, idx)}`
        default:
          return `${path} ${drawS(dataPoints, idx)}`
      }
    },
    ''
  )
}

export const drawSmoothPath = (dataPoints: Array<DataPoint>): string => {
  return dataPoints.reduce(
    (acc: string, point: DataPoint, i: number, points: Array<DataPoint>) =>
      i === 0 ? drawM(point) : `${acc} ${drawSmoothC(point, i, points)}`,
    ''
  )
}

export const drawM = ({ x, y }: DataPoint): string => `M ${x} ${y}`

export const drawS = (
  dataPoints: readonly DataPoint[],
  idx: number
): string => {
  const { x, y } = dataPoints[idx]
  const { x: xPrev } = dataPoints[idx - 1]

  const x2 = x - (x - xPrev) / 2
  const y2 = y

  return `S ${x2} ${y2}, ${x} ${y}`
}

export const drawC = (
  dataPoints: readonly DataPoint[],
  idx: number
): string => {
  const { x, y } = dataPoints[idx]
  const { x: xPrev, y: yPrev } = dataPoints[idx - 1]

  const x1 = xPrev + (x - xPrev) / 2
  const y1 = yPrev
  const x2 = x - (x - xPrev) / 2
  const y2 = y

  return `C ${x1} ${y1}, ${x2} ${y2}, ${x} ${y}`
}

export const drawSmoothC = (
  current: DataPoint,
  i: number,
  dataPoints: Array<DataPoint>
): string => {
  const { x: x1, y: y1 } = controlPointPosition(
    dataPoints[i - 1],
    dataPoints[i - 2],
    current
  )
  const { x: x2, y: y2 } = controlPointPosition(
    current,
    dataPoints[i - 1],
    dataPoints[i + 1],
    true
  )

  return `C ${x1} ${y1}, ${x2} ${y2}, ${current.x} ${current.y}`
}

export const line = (a: DataPoint, b: DataPoint): Line => {
  const lengthX = b.x - a.x
  const lengthY = b.y - a.y

  return {
    length: Math.sqrt(lengthX ** 2 + lengthY ** 2),
    angle: Math.atan2(lengthY, lengthX),
  }
}

export const controlPointPosition = (
  current: DataPoint,
  previous: DataPoint | undefined,
  next: DataPoint | undefined,
  reverse = false
): DataPoint => {
  previous = previous ?? current
  next = next ?? current

  const opposingLine = line(previous, next)
  const angle = opposingLine.angle + (reverse ? Math.PI : 0)
  const length = opposingLine.length * SMOOTHING_RATIO

  return {
    x: current.x + Math.cos(angle) * length,
    y: current.y + Math.sin(angle) * length,
  }
}
