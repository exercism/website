import * as React from 'react'
import { useRef } from 'react'

import {
  mapToSvgDimensions,
  minMaxNormalize,
  smoothDataPoints,
  transformCatmullRomSplineToBezierCurve,
} from './svg-graph-util'

interface IProgressGraph {
  data: Array<number>
  height: number
  width: number
  smooth?: boolean
}

export default function ProgressGraph({
  data,
  height,
  width,
}: IProgressGraph): JSX.Element {
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

  const normalizedData = minMaxNormalize(data)
  const dataPoints = mapToSvgDimensions(normalizedData, height, width)
  const smoothedDataPoints = smoothDataPoints(dataPoints, height)
  const path = transformCatmullRomSplineToBezierCurve(smoothedDataPoints)

  return (
    <svg
      className="c-progress-graph"
      viewBox={`-${hInset} -${vInset} ${width + 2 * hInset} ${
        height + 2 * vInset
      }`}
    >
      <defs>
        <mask
          id={`progress-graph-color-mask-${getRandomId()}`}
          x="0"
          y="0"
          width={width}
          height={height}
        >
          <path d={path} stroke="white" fill="transparent" />
        </mask>
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
        <rect
          x={`-${hInset}`}
          y={`-${vInset}`}
          width={`${width + 2 * hInset}`}
          height={`${height + 2 * vInset}`}
          stroke="none"
          fill={`url(#progress-graph-color-gradient-${getRandomId()})`}
          mask={`url(#progress-graph-color-mask-${getRandomId()})`}
        />
      </g>
    </svg>
  )
}
