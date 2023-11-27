import React from 'react'
import * as Skeleton from '../components'
import { randomIntBetween } from '@/utils/random-int-between'
import { generateComponents } from '@/utils/generateComponents'

export function ConceptMapSkeleton() {
  return (
    <div className="flex flex-col gap-[80px]">
      <ConceptRow length={1} />
      <ConceptRow length={2} />
      <ConceptRow length={3} />
    </div>
  )
}

function ConceptRow({ length }: { length: number }) {
  return (
    <div className="flex justify-around">
      {generateComponents({
        length,
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
          {generateComponents({
            length: randomIntBetween(1, 12),
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
