import React from 'react'
import * as Skeleton from '../components'

export function ConceptTooltipSkeleton() {
  return (
    <Skeleton.Wrapper className="flex flex-col gap-20">
      <div className="flex flex-row gap-12">
        <Skeleton.Shape
          shape="rect"
          style={{ width: '48px', height: '48px' }}
        />
        <Skeleton.Text
          className="justify-around"
          lines={2}
          minLength={25}
          maxLength={50}
        />
      </div>

      <Skeleton.Text lines={3} className="flex flex-col gap-8" />

      <div className="flex flex-row gap-12 items-center">
        <Skeleton.Shape shape="circle" style={{ width: 24, height: 24 }} />
        <Skeleton.Text lines={1} />
      </div>
      <Skeleton.Text
        lines={1}
        skeletonLineProps={{ style: { width: '100%', height: '2em' } }}
      />
    </Skeleton.Wrapper>
  )
}
