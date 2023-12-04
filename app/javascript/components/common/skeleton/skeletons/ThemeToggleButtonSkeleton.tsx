import React from 'react'
import { SkeletonShape } from '../components/SkeletonShape'
import { SkeletonLoader } from '../components/SkeletonLoader'

export function ThemeToggleButtonSkeleton() {
  return (
    <SkeletonLoader>
      <SkeletonShape
        shape="tag"
        className="ml-24"
        style={{ width: '52px', height: '26px' }}
      />
    </SkeletonLoader>
  )
}
