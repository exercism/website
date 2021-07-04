import { number } from 'prop-types'
import {
  minMaxNormalize,
  drawM,
  drawS,
  drawSmoothC,
  drawC,
  line,
  controlPointPosition,
  DataPoint,
} from '../../../../app/javascript/components/common/svg-graph-util'

describe('minMaxNormalize', () => {
  it('should normalize value between 0 an 1', () => {
    const values = [0, 1, 2, 3, 4, 5]
    const actual = minMaxNormalize(values)

    actual.forEach((v) => {
      expect(v).toBeGreaterThanOrEqual(0)
      expect(v).toBeLessThanOrEqual(1)
    })
  })

  it('should consider 0 as the minimum if 0 not included', () => {
    const values = [1, 2, 3, 4, 5]
    const actual = minMaxNormalize(values)
    expect(actual[0]).toEqual(0.2)
    expect(actual[1]).toEqual(0.4)
    expect(actual[2]).toEqual(0.6)
    expect(actual[3]).toEqual(0.8)
    expect(actual[4]).toEqual(1)
  })
})

describe('drawM', () => {
  it('returns a string with a svg M line command', () => {
    const dataPoint = mockDataPoint()
    const actual = drawM(dataPoint)

    expect(actual).toEqual('M 1 1')
  })
})

describe('drawS', () => {
  it('returns a string with a svg S line command', () => {
    const dataPoints = [mockDataPoint(), mockDataPoint(2, 2)]
    const actual = drawS(dataPoints, 1)

    expect(actual).toEqual('S 1.5 2, 2 2')
  })
})

describe('drawC', () => {
  it('returns a string with a svg S line command with smoothing math', () => {
    const dataPoints = [mockDataPoint(), mockDataPoint(2, 2)]
    const actual = drawC(dataPoints, 1)

    expect(actual).toEqual('C 1.5 1, 1.5 2, 2 2')
  })
})

describe('line', () => {
  it('returns an object describing a line segment', () => {
    const a = mockDataPoint(0, 0)
    const b = mockDataPoint(1, 1)
    const actual = line(a, b)

    expect(actual).toStrictEqual({
      length: Math.sqrt(2),
      angle: 0.7853981633974483,
    })
  })
})

type ControlPointTestCaseArgs = {
  current: DataPoint
  previous?: DataPoint
  next?: DataPoint
  reverse: boolean
  expected: DataPoint
}

type ControlPointTestCase = [string, ControlPointTestCaseArgs]

describe('controlPointPosition', () => {
  const testCases: ControlPointTestCase[] = [
    [
      'returns a DataPoint for the control point',
      {
        current: mockDataPoint(2, 2),
        previous: mockDataPoint(1, 1),
        next: mockDataPoint(3, 3),
        reverse: false,
        expected: { x: 2.4, y: 2.4 },
      },
    ],
    [
      'returns a DataPoint for the control point if previous does not exist',
      {
        current: mockDataPoint(2, 2),
        next: mockDataPoint(3, 3),
        reverse: false,
        expected: { x: 2.2, y: 2.2 },
      },
    ],
    [
      'returns a DataPoint for the control point if next does not exist',
      {
        current: mockDataPoint(2, 2),
        previous: mockDataPoint(1, 1),
        reverse: false,
        expected: { x: 2.2, y: 2.2 },
      },
    ],
    [
      'returns a DataPoint for the control point if next does not exist and reversed',
      {
        current: mockDataPoint(2, 2),
        previous: mockDataPoint(1, 1),
        reverse: true,
        expected: { x: 1.7999999999999998, y: 1.8 },
      },
    ],
  ]

  test.each<ControlPointTestCase>(testCases)(
    '%s',
    (name, { current, previous, next, reverse, expected }) => {
      const actual = controlPointPosition(current, previous, next, reverse)

      expect(actual).toStrictEqual(expected)
    }
  )
})

describe('drawSmoothC', () => {
  it('returns a string with a svg S line command with smoothing math', () => {
    const dataPoints = [
      mockDataPoint(0, 0),
      mockDataPoint(1, 1),
      mockDataPoint(2, 2),
      mockDataPoint(3, 3),
    ]
    const actual = drawSmoothC(dataPoints[2], 2, dataPoints)

    expect(actual).toEqual(
      'C 1.4000000000000001 1.4, 1.5999999999999999 1.6, 2 2'
    )
  })
})

function mockDataPoint(x = 1, y = 1): DataPoint {
  return {
    x,
    y,
  }
}
