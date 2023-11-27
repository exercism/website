import React from 'react'
import { randomIntBetween } from '@/utils/random-int-between'
import * as Skeleton from '../components'

export function ExerciseTooltipSkeleton() {
  return (
    <Skeleton.Wrapper className="flex flex-col gap-20 w-100">
      <div className="flex flex-row gap-20">
        <Skeleton.Shape
          shape="circle"
          style={{ width: '48px', height: '48px' }}
        />
        <div className="flex flex-col gap-16 justify-around w-100">
          <Skeleton.Line className="w-[70%]" style={{ height: '1.5em' }} />
          <div className="flex gap-8">
            <Skeleton.Shape
              shape="tag"
              style={{ width: randomIntBetween(80, 90), height: '2em' }}
            />
            <Skeleton.Shape
              shape="tag"
              style={{ width: randomIntBetween(80, 90), height: '2em' }}
            />
          </div>
        </div>
      </div>

      <Skeleton.Text lines={2} className="flex flex-col gap-8" />
    </Skeleton.Wrapper>
  )
}
