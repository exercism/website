import React from 'react'
import * as Skeleton from '../components'
import { randomIntBetween } from '@/utils/random-int-between'
import { repeatComponents } from '@/utils/repeatComponents'

export function TracksListSkeleton() {
  return (
    <Skeleton.Wrapper>
      <SearchBar />
      <TrackCards />
    </Skeleton.Wrapper>
  )
}

function SearchBar() {
  return (
    <div className="flex items-center mb-32 py-12 px-32 bg-backgroundColorA shadow-base justify-center">
      <Skeleton.Shape
        shape="rect"
        className="rounded-8 mr-0 md:mr-24 flex-grow"
        style={{ height: 48, maxWidth: '650px' }}
      />
      <Skeleton.Shape
        shape="rect"
        className="rounded-8 mr-40 flex-grow hidden-under-md"
        style={{ height: 48, maxWidth: '146px' }}
      />
      <Skeleton.Shape
        shape="rect"
        className="rounded-8 mr-48 flex-grow hidden-under-lg"
        style={{ height: 48, maxWidth: '210px' }}
      />
      <Skeleton.Shape
        shape="rect"
        className="rounded-8 flex-grow hidden-under-lg"
        style={{ height: 48, maxWidth: '250px' }}
      />
    </div>
  )
}

function TrackCards() {
  return (
    <div className="grid gap-16 grid-cols-1 md:grid-cols-2 lg-container container">
      {repeatComponents({
        times: 6,
        render(index) {
          return <TrackCard key={index} />
        },
      })}
    </div>
  )
}

function TrackCard() {
  return (
    <div className="bg-backgroundColorA shadow-base rounded-8 flex gap-16 py-20 px-24">
      <Skeleton.Shape shape="hex" style={{ width: 80, height: 80 }} />
      <div className="flex flex-col w-100">
        <div className="flex items-center gap-6 mb-16 justify-between">
          <Skeleton.Line
            style={{
              width: `${randomIntBetween(10, 18)}ch`,
              height: '1.6em',
            }}
          />
          <Skeleton.Shape
            shape="rect"
            className="rounded-5"
            style={{ width: 95, height: 33 }}
          />
        </div>

        <div className="flex items-center mb-12">
          <Skeleton.Shape
            shape="circle"
            className="mr-12"
            style={{ width: 21, height: 21 }}
          />
          <Skeleton.Line
            style={{
              width: '10ch',
              height: '1em',
            }}
          />
        </div>

        <Skeleton.Line
          style={{
            width: '100%',
            height: '6px',
          }}
          className="!rounded-100 mb-16"
        />

        <Skeleton.Line
          style={{
            width: '50%',
            height: '1em',
          }}
        />
      </div>
    </div>
  )
}
