import React from 'react'
import { CloseButton } from '../../session/CloseButton'
import { IterationView } from './RepresentationIterationView'
import RepresentationInfo from './RepresentationInfo'
import { CompleteRepresentationData, RepresentationData } from '../../../types'

export type PanesProps = {
  representation: RepresentationData
} & Pick<CompleteRepresentationData, 'links'>

export function LeftPane({ representation, links }: PanesProps): JSX.Element {
  return (
    <>
      <header className="discussion-header">
        <CloseButton url={links.back} />
        <RepresentationInfo
          exercise={representation.exercise}
          track={representation.track}
        />
      </header>
      <IterationView representationData={representation} />
    </>
  )
}
