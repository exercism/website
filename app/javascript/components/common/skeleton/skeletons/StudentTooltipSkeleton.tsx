import React from 'react'
import { randomIntBetween } from '@/utils/random-int-between'
import * as Skeleton from '../components'

export function StudentTooltipSkeleton() {
  return (
    <Skeleton.Wrapper className="flex flex-col w-[350px]">
      <div className="flex flex-row gap-20 mb-16">
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

      <Skeleton.Line style={{ width: '15ch' }} className="mb-8" />
      <Skeleton.Text
        lines={randomIntBetween(1, 4)}
        className="flex flex-col gap-8 mb-16"
      />

      <Skeleton.Line
        className="!rounded-8"
        style={{ width: '100', height: 'calc(1.6em + 16px)' }}
      />
    </Skeleton.Wrapper>
  )
}
