import React from 'react'
import { SkeletonShape } from '../components/SkeletonShape'
import { SkeletonLoader } from '../components/SkeletonLoader'

export function ReputationDropdownSkeleton() {
  return (
    <SkeletonLoader>
      <SkeletonShape
        shape="tag"
        style={{
          height: '38px',
          width: '100px',
        }}
      />
    </SkeletonLoader>
  )
}
