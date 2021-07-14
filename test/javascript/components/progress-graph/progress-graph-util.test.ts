import { number } from 'prop-types'
import {
  minMaxNormalize,
  mapToSvgDimensions,
  smoothDataPoints,
  transformCatmullRomSplineToBezierCurve,
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

  it('should handle a list of 0s', () => {
    const values = [0, 0, 0, 0, 0]
    const actual = minMaxNormalize(values)
    expect(actual).toStrictEqual([0, 0, 0, 0, 0])
  })
})

describe('mapToSvgDimensions', () => {
  it('should map an array of normalized values to data points', () => {
    const data = [0, 0.5, 1]
    const height = 100
    const width = 200

    const result = mapToSvgDimensions(data, height, width)

    expect(Array.isArray(result)).toBe(true)
    expect(result.length).toEqual(3)
    expect(result[0]).toStrictEqual({ x: 0, y: 95 })
    expect(result[1]).toStrictEqual({ x: 100, y: 50 })
    expect(result[2]).toStrictEqual({ x: 200, y: 5 })
  })

  test.each([
    [
      'less than 0',
      {
        data: [-1],
      },
    ],
    [
      'greater than 1',
      {
        data: [2],
      },
    ],
  ])('throws error for height %s', (_, { data }) => {
    expect(() => mapToSvgDimensions(data, 100, 100)).toThrow(
      'Normalized height must be between 0 and 1'
    )
  })
})

describe('smoothDataPoints', () => {
  test.each([
    [
      'should not smooth single datapoint',
      {
        dataPoints: [{ x: 50, y: 50 }],
        expected: [{ x: 50, y: 50 }],
        height: 100,
      },
    ],
    [
      'should not smooth two datapoints',
      {
        dataPoints: [
          { x: 50, y: 50 },
          { x: 60, y: 60 },
        ],
        expected: [
          { x: 50, y: 50 },
          { x: 60, y: 60 },
        ],
        height: 100,
      },
    ],
    [
      'should not smooth datapoints that are always increasing',
      {
        dataPoints: [
          { x: 50, y: 50 },
          { x: 60, y: 60 },
          { x: 70, y: 70 },
        ],
        expected: [
          { x: 50, y: 50 },
          { x: 60, y: 60 },
          { x: 70, y: 70 },
        ],
        height: 100,
      },
    ],
    [
      'should not smooth datapoints that are always decreasing',
      {
        dataPoints: [
          { x: 50, y: 70 },
          { x: 60, y: 60 },
          { x: 70, y: 50 },
        ],
        expected: [
          { x: 50, y: 70 },
          { x: 60, y: 60 },
          { x: 70, y: 50 },
        ],
        height: 100,
      },
    ],
    [
      'should not smooth datapoints that are always different',
      {
        dataPoints: [
          { x: 70, y: 70 },
          { x: 50, y: 50 },
          { x: 60, y: 60 },
        ],
        expected: [
          { x: 70, y: 70 },
          { x: 50, y: 50 },
          { x: 60, y: 60 },
        ],
        height: 100,
      },
    ],
    [
      'should not smooth datapoints when two are equal, but within "extremeness" threshold',
      {
        dataPoints: [
          { x: 0, y: 0 },
          { x: 10, y: 0 },
          { x: 20, y: 9 },
        ],
        expected: [
          { x: 0, y: 0 },
          { x: 10, y: 0 },
          { x: 20, y: 9 },
        ],
        height: 100,
      },
    ],
    [
      'should smooth when two are equal low, but next high greater "extremeness" threshold',
      {
        dataPoints: [
          { x: 0, y: 0 },
          { x: 10, y: 0 },
          { x: 20, y: 20 },
        ],
        expected: [
          { x: 0, y: 0 },
          { x: 10, y: 0 },
          {
            x: 12.5,
            y: 13.671875,
          },
          {
            x: 15,
            y: 18.75,
          },
          {
            x: 17.5,
            y: 19.921875,
          },
          { x: 20, y: 20 },
        ],
        height: 100,
      },
    ],
    [
      'should smooth when two are equal high, but next low greater "extremeness" threshold',
      {
        dataPoints: [
          { x: 0, y: 20 },
          { x: 10, y: 20 },
          { x: 20, y: 0 },
        ],
        expected: [
          { x: 0, y: 20 },
          { x: 10, y: 20 },
          {
            x: 12.5,
            y: 19.921875,
          },
          {
            x: 15,
            y: 18.75,
          },
          {
            x: 17.5,
            y: 13.671875,
          },
          { x: 20, y: 0 },
        ],
        height: 100,
      },
    ],
    [
      'should smooth when first is high, but next low greater "extremeness" threshold',
      {
        dataPoints: [
          { x: 0, y: 20 },
          { x: 10, y: 0 },
          { x: 20, y: 0 },
        ],
        expected: [
          {
            x: 0,
            y: 20,
          },
          {
            x: 2.5,
            y: 19.921875,
          },
          {
            x: 5,
            y: 18.75,
          },
          {
            x: 7.5,
            y: 13.671875,
          },
          {
            x: 10,
            y: 0,
          },
          {
            x: 20,
            y: 0,
          },
        ],
        height: 100,
      },
    ],
  ])('%s', (_, { expected, dataPoints, height }) => {
    const result = smoothDataPoints(dataPoints, height)
    expect(result).toStrictEqual(expected)
  })
})

describe('transformCatmullRomSplineToBezierCurve', () => {
  it('should throw error when less than 3 datapoints supplied', () => {
    const data = [mockDataPoint(1, 1), mockDataPoint(2, 2)]

    expect(() => transformCatmullRomSplineToBezierCurve(data)).toThrow(
      'Graph requires at least 3 data points'
    )
  })

  test.each([
    [
      'inline',
      {
        data: [mockDataPoint(0, 0), mockDataPoint(1, 0), mockDataPoint(2, 0)],
        expected:
          'M 0 0 C 0.16666666666666666 0, 0.6666666666666666 0, 1 0 C 1.3333333333333333 0, 1.8333333333333333 0, 2 0',
      },
    ],
    [
      'hump',
      {
        data: [mockDataPoint(0, 0), mockDataPoint(), mockDataPoint(2, 0)],
        expected:
          'M 0 0 C 0.16666666666666666 0.16666666666666666, 0.6666666666666666 1, 1 1 C 1.3333333333333333 1, 1.8333333333333333 0.16666666666666666, 2 0',
      },
    ],
    [
      'increasing',
      {
        data: [mockDataPoint(0, 0), mockDataPoint(1, 1), mockDataPoint(2, 2)],
        expected:
          'M 0 0 C 0.16666666666666666 0.16666666666666666, 0.6666666666666666 0.6666666666666666, 1 1 C 1.3333333333333333 1.3333333333333333, 1.8333333333333333 1.8333333333333333, 2 2',
      },
    ],
    [
      'decreasing',
      {
        data: [mockDataPoint(0, 2), mockDataPoint(1, 1), mockDataPoint(2, 0)],
        expected:
          'M 0 2 C 0.16666666666666666 1.8333333333333333, 0.6666666666666666 1.3333333333333333, 1 1 C 1.3333333333333333 0.6666666666666666, 1.8333333333333333 0.16666666666666666, 2 0',
      },
    ],
  ])(
    'should draw a bezier spline from catmullrom spline data points - %s',
    (_, { data, expected }) => {
      const result = transformCatmullRomSplineToBezierCurve(data)
      expect(result).toEqual(expected)
    }
  )
})

function mockDataPoint(x = 1, y = 1): DataPoint {
  return {
    x,
    y,
  }
}
