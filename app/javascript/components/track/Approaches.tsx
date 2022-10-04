import React from 'react'
import {
  ApproachExamples,
  CommunityVideos,
  DiggingDeeper,
} from './approaches-elements'

export function Approaches(): JSX.Element {
  return (
    <div className="lg-container grid grid-cols-3 gap-40">
      <LeftSide />
      <RightSide />
    </div>
  )
}

function LeftSide(): JSX.Element {
  return (
    <div className="col-span-2">
      <DiggingDeeper html="" />
      <CommunityVideos />
    </div>
  )
}

function RightSide(): JSX.Element {
  return (
    <div className="col-span-1">
      <ApproachExamples />
    </div>
  )
}
