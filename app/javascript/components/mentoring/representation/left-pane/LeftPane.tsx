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

// const backlink = useMemo(() => {
//   const storedItem =
//     localStorage.getItem(
//       `representation-${
//         withoutFeedback === 'without_feedback'
//           ? 'without_feedback'
//           : 'with_feedback'
//       }-queries`
//     ) || ''

// let parsed
// try {
//   parsed = JSON.parse(storedItem)
// } catch {
//   parsed = {}
// }

// console.log("")
// const decamelized = decamelizeKeys(parsed)
// const storedQuery = new URLSearchParams(
//   decamelized as unknown as URLSearchParams
// )

// console.log('STORED Q:', storedQuery)

// return `${links.back}${
//   storedQuery.getAll.length > 0 ? `?${storedQuery}` : ''
// }`
// }, [links])
