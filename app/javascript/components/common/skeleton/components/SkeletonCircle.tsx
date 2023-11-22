import React from 'react'

type SkeletonCircleProps = Record<'width' | 'height', string | number>

export function SkeletonCircle({ width, height }: SkeletonCircleProps) {
  return <div className="skeleton-box circle" style={{ width, height }} />
}
