import React from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'

export type SkeletonShapeProps = Record<'width' | 'height', string | number>

export function SkeletonLine(props: React.HTMLProps<HTMLDivElement>) {
  return (
    <div
      {...props}
      className={assembleClassNames('skeleton-box line', props.className)}
    />
  )
}
