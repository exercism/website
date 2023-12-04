import React from 'react'
import { SkeletonShape } from '../components/SkeletonShape'
import { SkeletonLoader } from '../components/SkeletonLoader'

export function NotificationsDropdownSkeleton() {
  return (
    <SkeletonLoader>
      <SkeletonShape
        shape="rect"
        style={{
          borderRadius: '8px',
          height: '37px',
          width: '41px',
          marginRight: '48px',
          marginLeft: '8px',
        }}
      />
    </SkeletonLoader>
  )
}
