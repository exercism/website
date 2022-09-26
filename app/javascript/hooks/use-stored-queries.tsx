import { useLocalStorage } from '../utils/use-storage'
import { ListQuery } from './use-list'
import { decamelizeKeys } from 'humps'

export type RepresentationParsedQueries = {
  withFeedback: string
  withoutFeedback: string
}

export function useStoredRepresentationQueries(
  withFeedback: boolean,
  initData: ListQuery
): {
  parsedQueries: RepresentationParsedQueries
  setLocalQueries: (value: ListQuery) => void
} {
  const [, setLocalQueries] = useLocalStorage(
    withFeedback
      ? 'representation-with_feedback-queries'
      : 'representation-without_feedback-queries',
    initData
  )

  const [withFeedbackQueries] = useLocalStorage(
    'representation-with_feedback-queries',
    initData
  )
  const [withoutFeedbackQueries] = useLocalStorage(
    'representation-without_feedback-queries',
    initData
  )

  const parsedQueries = {
    withFeedback: new URLSearchParams(
      decamelizeKeys(withFeedbackQueries) as URLSearchParams
    ).toString(),
    withoutFeedback: new URLSearchParams(
      decamelizeKeys(withoutFeedbackQueries) as URLSearchParams
    ).toString(),
  }

  return { parsedQueries, setLocalQueries }
}
