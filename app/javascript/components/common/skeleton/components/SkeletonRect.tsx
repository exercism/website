import React from 'react'
import { SkeletonShapeProps } from './SkeletonLine'

export function SkeletonRect({ width, height }: SkeletonShapeProps) {
  return <div className="skeleton-box rect" style={{ width, height }} />
}
