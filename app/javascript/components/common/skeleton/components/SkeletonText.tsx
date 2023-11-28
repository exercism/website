import React, { useMemo } from 'react'
import { SkeletonLine } from './SkeletonLine'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { randomIntBetween } from '@/utils/random-int-between'

export function SkeletonText({
  lines,
  minLength = 65,
  maxLength = 95,
  skeletonLineProps,
  ...props
}: {
  lines: number
  minLength?: number
  maxLength?: number
  skeletonLineProps?: React.HTMLProps<HTMLDivElement>
} & React.HTMLProps<HTMLDivElement>) {
  const lineLength = useMemo(
    () => generateRandomLineLength(lines, minLength, maxLength),
    [lines]
  )
  return (
    <div
      {...props}
      className={assembleClassNames('skeleton-text gap-8', props.className)}
    >
      {Array.from({ length: lines }).map((_, idx) => (
        <SkeletonLine
          key={idx}
          {...skeletonLineProps}
          style={{
            width: skeletonLineProps?.style?.width || lineLength[idx] + '%',
            height: skeletonLineProps?.style?.height || '1em',
          }}
        />
      ))}
    </div>
  )
}

function generateRandomLineLength(
  lines: number,
  min: number,
  max: number
): number[] {
  return Array.from({ length: lines }).map(() => randomIntBetween(min, max))
}
