export type DataPoint = {
  x: number
  y: number
}

export type Line = {
  length: number
  angle: number
}
const SIMILAR_THRESHOLD_DELTA = 0.01
const SMOOTHING_THRESHOLD_DELTA = 0.2
const INTERPOLATION_STEPS = 3
const SEGMENT_PARTS = INTERPOLATION_STEPS + 1

export const minMaxNormalize = (data: Array<number>): Array<number> => {
  const min = Math.min(0, ...data)
  const max = Math.max(...data)

  if (max === 0 && min === 0) {
    return data
  }

  return data.map((n) => (n - min) / (max - min))
}

export const mapToSvgDimensions = (
  data: number[],
  height: number,
  width: number
): DataPoint[] => {
  // due to the nature of bezier splines, some curves can go outside the boundaries without this buffer
  const vBuffer = height * 0.05
  const step = width / (data.length - 1)

  return data.map((normalizedHeight: number, index: number) => {
    if (normalizedHeight < 0 || normalizedHeight > 1) {
      throw new Error('Normalized height must be between 0 and 1')
    }

    return {
      x: index * step,
      y: height - vBuffer - (height - 2 * vBuffer) * normalizedHeight, // SVG coordinates start from the upper left corner
    } as DataPoint
  })
}

/**
 * With splines (bezier or catmull-rom) when there are large differences in values, in order to
 * keep the curve smooth, it often will vary above or below the baseline since they must touch all
 * of the points.  This function examines the list of data points, and if there is an extreme difference
 * attempts to prevent the dipping above or below the baseline by interpolating points to guide the curve
 */
export const smoothDataPoints = (
  dataPoints: DataPoint[],
  height: number
): DataPoint[] => {
  return dataPoints.reduce(
    (
      acc: DataPoint[],
      dataPoint: DataPoint,
      index: number,
      dataPoints: readonly DataPoint[]
    ) => {
      const prevPoint = dataPoints[index - 1]
      const nextPoint = dataPoints[index + 1]
      const nextNextPoint = dataPoints[index + 2]

      const isLastPoint = index === dataPoints.length - 1
      const isFlatLineSegmentFromPrevToCurrent = prevPoint
        ? areDataPointsWithinPercentDelta(
            prevPoint,
            dataPoint,
            height,
            SIMILAR_THRESHOLD_DELTA
          )
        : false
      const isFlatLineSegmentFromNextToNextNext =
        nextPoint && nextNextPoint
          ? areDataPointsWithinPercentDelta(
              nextPoint,
              nextNextPoint,
              height,
              SIMILAR_THRESHOLD_DELTA
            )
          : false

      if (
        isLastPoint ||
        (!isFlatLineSegmentFromPrevToCurrent &&
          !isFlatLineSegmentFromNextToNextNext)
      ) {
        acc.push(dataPoint)
        return acc
      }

      if (
        areDataPointsWithinPercentDelta(
          dataPoint,
          nextPoint,
          height,
          SMOOTHING_THRESHOLD_DELTA
        )
      ) {
        acc.push(dataPoint)
        return acc
      }

      const easingFunction =
        dataPoint.y > nextPoint.y ? quartEaseInFunction : quartEaseOutFunction

      /**
       * At this point, has been determined that the curve will be arbitrarily "sharp",
       * so will interpolate some points to smooth the spline towards the next point.
       * Method:
       *  - Find the slope of the line between the two points
       *  - find the y intercepts when x = 0
       *  - use `y = mx + c` to create points between the two points with an easing
       *    function
       */
      const slope = (nextPoint.y - dataPoint.y) / (nextPoint.x - dataPoint.x)
      const yIntercept = dataPoint.y - slope * dataPoint.x
      const dx = nextPoint.x - dataPoint.x

      const interpolatedPoints = new Array(INTERPOLATION_STEPS)
        .fill(null)
        .map((_, step) => getTimeAtStep(step))
        .map((t) => easingFunction(t))
        .map(
          (easedT, i): DataPoint => {
            return {
              x: dataPoint.x + getTimeAtStep(i) * dx,
              y: slope * (dataPoint.x + easedT * dx) + yIntercept, // y = mx + c
            }
          }
        )

      acc.push(dataPoint, ...interpolatedPoints)

      return acc
    },
    []
  )
}

const areDataPointsWithinPercentDelta = (
  a: DataPoint | null | undefined,
  b: DataPoint | null | undefined,
  height: number,
  delta: number
) => {
  if (!a || !b) {
    return false
  }

  const aHeightPercent = a.y / height
  const bHeightPercent = b.y / height

  return Math.abs(aHeightPercent - bHeightPercent) < delta
}

const getTimeAtStep = (step: number): number => (1 / SEGMENT_PARTS) * (step + 1)

const quartEaseInFunction = (t: number): number => t * t * t * t
const quartEaseOutFunction = (t: number): number => 1 - --t * t * t * t

/**
 * Takes a sequence of CatmullRom Spline points and returns a smooth SVG Bezier
 * Curve draw command. Adapted under the MIT license from:
 * http://schepers.cc/svg/path/catmullrom2bezier.js
 */
export const transformCatmullRomSplineToBezierCurve = (
  dataPoints: Array<DataPoint>
): string => {
  if (dataPoints.length < 3) {
    throw new Error('Graph requires at least 3 data points')
  }

  let path = drawM(dataPoints[0])

  for (let index = 0; index < dataPoints.length - 1; index += 1) {
    const points: Array<DataPoint> = []
    if (index === 0) {
      points.push(dataPoints[index])
      points.push(dataPoints[index])
      points.push(dataPoints[index + 1])
      points.push(dataPoints[index + 2])
    } else if (index === dataPoints.length - 2) {
      points.push(dataPoints[index - 1])
      points.push(dataPoints[index])
      points.push(dataPoints[index + 1])
      points.push(dataPoints[index + 1])
    } else {
      points.push(dataPoints[index - 1])
      points.push(dataPoints[index])
      points.push(dataPoints[index + 1])
      points.push(dataPoints[index + 2])
    }

    path += ' ' + drawC(points[0], points[1], points[2], points[3])
  }

  return path
}

/**
 * Draw point as SVG Move command
 */
const drawM = ({ x, y }: DataPoint): string => `M ${x} ${y}`

/**
 * Translates 4 points from a CatmullRom Spline into an SVG Bezier Curve command
 */
const drawC = (
  p0: DataPoint,
  p1: DataPoint,
  p2: DataPoint,
  p3: DataPoint
): string => {
  const x1 = (-p0.x + 6 * p1.x + p2.x) / 6
  const y1 = (-p0.y + 6 * p1.y + p2.y) / 6
  const x2 = (p1.x + 6 * p2.x - p3.x) / 6
  const y2 = (p1.y + 6 * p2.y - p3.y) / 6
  const x = p2.x
  const y = p2.y

  return `C ${x1} ${y1}, ${x2} ${y2}, ${x} ${y}`
}
