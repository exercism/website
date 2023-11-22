import React from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'

export function SkeletonLoader({
  children,
  ...props
}: { children: React.ReactNode } & React.HTMLProps<HTMLDivElement>) {
  return (
    <div
      {...props}
      className={assembleClassNames('c-skeleton-loader', props.className)}
    >
      {children}
    </div>
  )
}
