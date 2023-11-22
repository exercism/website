import React from 'react'
import { SkeletonLoader } from '../components/SkeletonLoader'

export function ConceptTooltipSkeleton() {
  return (
    <SkeletonLoader
      blocks={[
        {
          elements: [
            { type: 'rect', width: '48px', height: '48px' },
            { type: 'text', lines: 2 },
          ],
          style: {},
        },

        {
          elements: [{ type: 'text', lines: 2 }],
          style: {},
        },
        {
          elements: [
            { type: 'circle', width: '24px', height: '24px' },
            { type: 'text', lines: 1 },
          ],
          style: {},
        },
      ]}
      gap="20px"
    />
  )
}
