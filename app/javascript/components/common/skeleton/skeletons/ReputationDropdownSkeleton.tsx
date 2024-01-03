import React from 'react'
import { SkeletonShape } from '../components/SkeletonShape'
import { SkeletonLoader } from '../components/SkeletonLoader'

// pl-70 comes from:
// px-16 + 24px icon with mr-8 + 3px border
// 32 + 24 + 8 + 6
export function ReputationDropdownSkeleton({
  reputation,
}: {
  reputation: string
}) {
  return (
    <SkeletonLoader>
      <SkeletonShape
        shape="tag"
        className="font-bold text-16 pl-[70px]"
        style={{
          height: '38px',
        }}
      >
        {reputation}
      </SkeletonShape>
    </SkeletonLoader>
  )
}
