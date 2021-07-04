import * as React from 'react'
import { useRef } from 'react'

import {
  minMaxNormalize,
  drawSegmentPath,
  drawSmoothPath,
  DataPoint,
} from './svg-graph-util'

interface IProgressGraph {
  data: Array<number>
  height: number
  width: number
  smooth?: boolean
}

export const ProgressGraph: React.FC<IProgressGraph> = ({
  data,
  height,
  width,
  smooth = false,
}) => {
  const randomIdRef = useRef<null | number>(null)

  function getRandomId() {
    const currentId = randomIdRef.current
    if (currentId !== null) {
      return currentId
    }
    const newId = Math.floor(Math.random() * 10000)
    randomIdRef.current = newId
    return newId
  }

  const aspectRatio = width / height
  const hInset = height * 0.1
  const vInset = Math.round(hInset / aspectRatio)
  const vBuffer = height * 0.05 // due to smoothing, some curves can go outside the boundaries without this buffer

  const step = width / (data.length - 1)
  const normalizedData = minMaxNormalize(data)
  const dataPoints = normalizedData.map(
    (n, i) =>
      ({
        x: i * step,
        y: height - vBuffer - (height - vBuffer) * n, // SVG coordinates start from the upper left corner
      } as DataPoint)
  )
  const path = smooth ? drawSmoothPath(dataPoints) : drawSegmentPath(dataPoints)

  return (
    <svg
      className="c-progress-graph"
      viewBox={`-${hInset} -${vInset} ${width + 2 * hInset} ${
        height + 2 * vInset
      }`}
    >
      <defs>
        <linearGradient
          id={`progress-graph-color-gradient-${getRandomId()}`}
          x1="0%"
          y1="0%"
          x2="0%"
          y2="100%"
        >
          <stop
            offset="5%"
            style={{ stopColor: 'var(--progress-graph-first-color, black)' }}
          />
          <stop
            offset="95%"
            style={{ stopColor: 'var(--progress-graph-last-color, black)' }}
          />
        </linearGradient>
      </defs>

      <g>
        <path
          d={path}
          stroke={`url(#progress-graph-color-gradient-${getRandomId()})`}
          fill="transparent"
        />
      </g>
    </svg>
  )
}
