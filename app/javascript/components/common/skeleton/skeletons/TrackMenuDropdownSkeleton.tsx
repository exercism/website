import React from 'react'
import { SkeletonShape } from '../components/SkeletonShape'
import { SkeletonLoader } from '../components/SkeletonLoader'

export function TrackMenuDropdownSkeleton() {
  return (
    <SkeletonLoader>
      <SkeletonShape
        shape="rect"
        style={{ width: '32px', height: '32px', borderRadius: '5px' }}
      />
    </SkeletonLoader>
  )
}
