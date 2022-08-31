import React from 'react'
import { CloseButton } from '../../session/CloseButton'
import { IterationView } from './RepresentationIterationView'
import RepresentationInfo from './RepresentationInfo'
import { RepresentationData } from '../../../types'

export type PanesProps = {
  data: RepresentationData
}

export function LeftPane({ data }: PanesProps): JSX.Element {
  console.log(data)
  return (
    <>
      <header className="discussion-header">
        <CloseButton url={''} />
        <RepresentationInfo exercise={data.exercise} track={data.track} />
      </header>
      <IterationView representationData={data} />
    </>
  )
}
