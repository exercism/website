import React from 'react'
import { randomIntBetween } from '@/utils/random-int-between'
import * as Skeleton from '../components'

export function UserTooltipSkeleton() {
  return (
    <Skeleton.Wrapper className="flex flex-col w-100">
      <div className="flex flex-row gap-20 mb-16 ">
        <Skeleton.Shape
          shape="circle"
          style={{ width: '48px', height: '48px' }}
        />

        <Skeleton.Text
          lines={2}
          className="flex flex-col gap-8 place-self-center"
        />
        <Skeleton.Shape
          shape="tag"
          className="place-self-center"
          style={{ width: randomIntBetween(120, 170), height: '30px' }}
        />
      </div>

      <Skeleton.Text lines={3} className="flex flex-col gap-8 mb-16" />

      <div className="flex items-center">
        <Skeleton.Shape
          shape="circle"
          style={{ width: 16, height: 16 }}
          className="mr-12"
        />
        <Skeleton.Line style={{ width: '50px' }} />
      </div>
    </Skeleton.Wrapper>
  )
}
