import React from 'react'
import { SkeletonLoader } from '../components/SkeletonLoader'

export function ConceptTooltipSkeleton() {
  return (
    <SkeletonLoader
      blocks={[
        {
          elements: [
            {
              type: 'rect',
              props: { style: { width: '48px', height: '48px' } },
            },
            { type: 'text', props: { lines: 2 } },
          ],
        },
        {
          elements: [{ type: 'text', props: { lines: 2 } }],
        },
        {
          elements: [
            {
              type: 'circle',
              props: { style: { width: '24px', height: '24px' } },
            },
            { type: 'text', props: { lines: 1 } },
          ],
        },
      ]}
      style={{ gap: '20px' }}
    />
  )
}
