import React from 'react'
import { SkeletonLoader } from '../components/SkeletonLoader'
import { SkeletonShape } from '../components/SkeletonShape'
import { SkeletonText } from '../components/SkeletonText'

export function ConceptTooltipSkeleton() {
  return (
    <SkeletonLoader className="flex flex-col gap-20">
      <div className="flex flex-row gap-12">
        <SkeletonShape shape="rect" style={{ width: '48px', height: '48px' }} />
        <SkeletonText
          className="justify-around"
          lines={2}
          minLength={25}
          maxLength={50}
        />
      </div>

      <SkeletonText lines={3} className="flex flex-col gap-8" />

      <div className="flex flex-row gap-12 items-center">
        <SkeletonShape shape="circle" style={{ width: 24, height: 24 }} />
        <SkeletonText lines={1} />
      </div>
      <SkeletonText
        lines={1}
        skeletonLineProps={{ style: { width: '100%', height: '2em' } }}
      />
    </SkeletonLoader>
  )
}
