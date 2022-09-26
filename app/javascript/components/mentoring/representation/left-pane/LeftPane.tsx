import React, { useMemo } from 'react'
import { CloseButton } from '../../session/CloseButton'
import { IterationView } from './RepresentationIterationView'
import RepresentationInfo from './RepresentationInfo'
import { CompleteRepresentationData, RepresentationData } from '../../../types'
import { useLogger } from '../../../../hooks'
import { useLocalStorage } from '../../../../utils/use-storage'
import { decamelize, decamelizeKeys } from 'humps'

export type PanesProps = {
  representation: RepresentationData
} & Pick<CompleteRepresentationData, 'links'>

export function LeftPane({ representation, links }: PanesProps): JSX.Element {
  const backlink = useMemo(() => {
    const backLinkArray = links.back.split('/')
    const withoutFeedback = backLinkArray[backLinkArray.length - 1]

    const storedItem =
      localStorage.getItem(
        `representation-${
          withoutFeedback === 'without_feedback'
            ? 'without_feedback'
            : 'with_feedback'
        }-queries`
      ) || ''

    let parsed
    try {
      parsed = JSON.parse(storedItem)
    } catch {
      parsed = {}
    }

    const decamelized = decamelizeKeys(parsed)
    const storedQuery = new URLSearchParams(
      decamelized as unknown as URLSearchParams
    )

    console.log('STORED Q:', storedQuery)

    return `${links.back}${
      storedQuery.getAll.length > 0 ? `?${storedQuery}` : ''
    }`
  }, [links])
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
