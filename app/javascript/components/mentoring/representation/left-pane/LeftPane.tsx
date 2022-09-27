import React, { useMemo } from 'react'
import { CloseButton } from '../../session/CloseButton'
import { IterationView } from './RepresentationIterationView'
import RepresentationInfo from './RepresentationInfo'
import { CompleteRepresentationData, RepresentationData } from '../../../types'
import { useStoredRepresentationQueries } from '../../../../hooks/use-stored-queries'

export type PanesProps = {
  representation: RepresentationData
} & Pick<CompleteRepresentationData, 'links'>

const INIT_DATA = {
  page: 1,
  criteria: '',
}

export function LeftPane({ representation, links }: PanesProps): JSX.Element {
  const withFeedback = useMemo(() => {
    const backLinkArray = links.back.split('/')
    return backLinkArray.pop() === 'with_feedback'
  }, [links])

  const { parsedQueries } = useStoredRepresentationQueries(
    withFeedback,
    INIT_DATA
  )

  const backlink = useMemo(() => {
    return (
      links.back +
      '?' +
      (withFeedback
        ? parsedQueries.withFeedback
        : parsedQueries.withoutFeedback)
    )
  }, [
    links.back,
    parsedQueries.withFeedback,
    parsedQueries.withoutFeedback,
    withFeedback,
  ])

  return (
    <>
      <header className="discussion-header">
        <CloseButton url={backlink} />
        <RepresentationInfo
          exercise={representation.exercise}
          track={representation.track}
        />
      </header>
      <IterationView representationData={representation} />
    </>
  )
}
