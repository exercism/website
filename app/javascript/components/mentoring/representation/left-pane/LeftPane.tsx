import React from 'react'
import { CloseButton } from '../../session/CloseButton'
import { IterationView } from './RepresentationIterationView'
import RepresentationInfo from './RepresentationInfo'
import { CompleteRepresentationData, RepresentationData } from '../../../types'

export type PanesProps = {
  data: RepresentationData
} & Pick<CompleteRepresentationData, 'links'>

export function LeftPane({ data, links }: PanesProps): JSX.Element {
  return (
    <>
      <header className="discussion-header">
        <CloseButton url={links.back} />
        <RepresentationInfo exercise={data.exercise} track={data.track} />
      </header>
      <IterationView representationData={data} />
    </>
  )
}
