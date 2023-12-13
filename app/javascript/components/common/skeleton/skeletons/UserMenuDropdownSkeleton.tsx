import React from 'react'
import { SkeletonShape } from '../components/SkeletonShape'
import { SkeletonLoader } from '../components/SkeletonLoader'

export function UserMenuDropdownSkeleton() {
  return (
    <SkeletonLoader>
      <SkeletonShape
        shape="circle"
        style={{
          height: '42px',
          width: '42px',
        }}
      />
    </SkeletonLoader>
  )
}
