import React from 'react'
import * as Skeleton from '../components'
import { randomIntBetween } from '@/utils/random-int-between'
import { repeatComponents } from '@/utils/repeatComponents'

export function ConceptMapSkeleton() {
  return (
    <div className="flex flex-col gap-[80px]">
      <ConceptRow times={1} />
      <ConceptRow times={2} />
      <ConceptRow times={3} />
    </div>
  )
}

function ConceptRow({ times }: { times: number }) {
  return (
    <div className="flex justify-around">
      {repeatComponents({
        times,
        render: (index) => <Concept key={index} />,
      })}
    </div>
  )
}

function Concept() {
  return (
    <div className="bg-backgroundColorA shadow-baseZ1 padding rounded-8">
      <Skeleton.Wrapper className="flex flex-col">
        <div className="py-16 px-24">
          <div className="flex flex-row gap-16 items-center justify-center">
            <Skeleton.Shape shape="rect" style={{ width: 32, height: 32 }} />
            <Skeleton.Line
              style={{ width: randomIntBetween(120, 200), height: '1.6em' }}
            />
          </div>
        </div>

        <div className="flex py-10 px-24 border-t-1 border-borderColor7 justify-center">
          {repeatComponents({
            times: randomIntBetween(1, 12),
            render: (index) => (
              <Skeleton.Shape
                key={index}
                shape="circle"
                className="m-6"
                style={{ width: 24, height: 24 }}
              />
            ),
          })}
        </div>
      </Skeleton.Wrapper>
    </div>
  )
}
