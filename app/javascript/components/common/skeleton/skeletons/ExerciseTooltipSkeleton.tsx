import React from 'react'
import { SkeletonLoader } from '../components/SkeletonLoader'
import { SkeletonShape } from '../components/SkeletonShape'
import { SkeletonText, randomIntBetween } from '../components/SkeletonText'
import { SkeletonLine } from '../components/SkeletonLine'

export function ExerciseTooltipSkeleton() {
  return (
    <SkeletonLoader className="flex flex-col gap-20 w-100">
      <div className="flex flex-row gap-20">
        <SkeletonShape
          shape="circle"
          style={{ width: '48px', height: '48px' }}
        />
        <div className="flex flex-col gap-16 justify-around w-100">
          <SkeletonLine className="w-[70%]" style={{ height: '1.5em' }} />
          <div className="flex gap-8">
            <SkeletonShape
              shape="tag"
              style={{ width: randomIntBetween(80, 90), height: '2em' }}
            />
            <SkeletonShape
              shape="tag"
              style={{ width: randomIntBetween(80, 90), height: '2em' }}
            />
          </div>
        </div>
      </div>

      <SkeletonText lines={2} className="flex flex-col gap-8" />
    </SkeletonLoader>
  )
}
