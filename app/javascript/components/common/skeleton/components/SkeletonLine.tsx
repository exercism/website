import React from 'react'

export type SkeletonShapeProps = Record<'width' | 'height', string | number>

export function SkeletonLine({ width, height }: SkeletonShapeProps) {
  return (
    <div
      className="skeleton-box line"
      style={{ width, height, lineHeight: '160%' }}
    />
  )
}
