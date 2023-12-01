import React from 'react'
import * as Skeleton from '../components'
import { randomIntBetween } from '@/utils/random-int-between'
import { repeatComponents } from '@/utils/repeatComponents'

export function ExerciseListSkeleton() {
  return (
    <Skeleton.Wrapper className="lg-container container">
      <SearchBar />
      <Tabs />
      <ExerciseCards />
    </Skeleton.Wrapper>
  )
}

function SearchBar() {
  return (
    <Skeleton.Line
      className="!rounded-8 mb-32"
      style={{ height: 48, width: 440 }}
    />
  )
}

function Tabs() {
  return (
    <div className="flex items-center gap-40 mb-32">
      <Skeleton.Shape shape="tag" style={{ height: 40, width: 160 }} />
      {repeatComponents({
        times: 4,
        render(index) {
          return <TabElement key={index} />
        },
      })}
    </div>
  )
}

function TabElement() {
  return (
    <div className="flex items-center">
      <Skeleton.Shape
        shape="circle"
        className="mr-12"
        style={{ height: 16, width: 16 }}
      />
      <Skeleton.Line className="mr-8" style={{ width: '8ch' }} />
      <Skeleton.Line style={{ width: '2ch' }} />
    </div>
  )
}

function ExerciseCards() {
  return (
    <div className="grid gap-16 grid-cols-1 md:grid-cols-2">
      {repeatComponents({
        times: 4,
        render(index) {
          return <ExerciseCard key={index} />
        },
      })}
    </div>
  )
}

function ExerciseCard() {
  return (
    <div className="bg-backgroundColorA shadow-base rounded-8 flex gap-16 py-16 px-24">
      <Skeleton.Shape shape="circle" style={{ width: 64, height: 64 }} />
      <div className="flex flex-col w-100">
        <div className="flex items-center gap-6 mb-8">
          {repeatComponents({
            times: randomIntBetween(1, 3),
            render(index) {
              return (
                <Skeleton.Line
                  key={index}
                  style={{
                    width: `${randomIntBetween(10, 18)}ch`,
                    height: '1.6em',
                  }}
                />
              )
            },
          })}
        </div>

        <Skeleton.Shape
          shape="tag"
          className="mb-12"
          style={{ width: 90, height: 30 }}
        />

        <Skeleton.Text lines={2} />
      </div>
    </div>
  )
}
