import { useLocalStorage } from '../utils/use-storage'
import { decamelizeKeys } from 'humps'

export type RepresentationParsedQueries = {
  withFeedback: string
  withoutFeedback: string
}

export function useStoredRepresentationQueries(
  withFeedback: boolean,
  initData: Record<string, unknown>
): {
  parsedQueries: RepresentationParsedQueries
  setLocalQueries: (value: Record<string, unknown>) => void
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
