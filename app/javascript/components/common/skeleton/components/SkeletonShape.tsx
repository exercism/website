import React from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'

export function SkeletonShape({
  shape,
  ...props
}: {
  shape: 'rect' | 'circle' | 'tag' | 'hex'
} & React.HTMLProps<HTMLDivElement>): JSX.Element {
  return (
    <div
      {...props}
      className={assembleClassNames('skeleton-box', shape, props.className)}
    />
  )
}
