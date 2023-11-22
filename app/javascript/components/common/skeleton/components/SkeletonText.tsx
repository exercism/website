import React, { useMemo } from 'react'
import { SkeletonLine } from './SkeletonLine'

export function SkeletonText({ lines }) {
  const lineLength = useMemo(() => generateRandomLineLength(lines), [lines])
  return (
    <div className="skeleton-text">
      {Array.from({ length: lines }).map((_, idx) => (
        <SkeletonLine width={lineLength[idx] + '%'} height="1em" />
      ))}
    </div>
  )
}

function randomIntFromInterval(min: number, max: number): number {
  return Math.floor(Math.random() * (max - min + 1) + min)
}

function generateRandomLineLength(lines: number): number[] {
  return Array.from({ length: lines }).map(() => randomIntFromInterval(70, 100))
}
