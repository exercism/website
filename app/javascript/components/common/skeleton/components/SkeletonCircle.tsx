import React from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'

export function SkeletonShape(
  { shape },
  props: React.HTMLProps<HTMLDivElement>
): JSX.Element {
  return (
    <div
      className={assembleClassNames('skeleton-box', shape, props.className)}
    />
  )
}
