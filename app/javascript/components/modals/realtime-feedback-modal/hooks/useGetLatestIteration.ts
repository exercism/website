import { useEffect, useState } from 'react'
import { useQueryClient } from '@tanstack/react-query'
import { usePaginatedRequestQuery } from '@/hooks/request-query'
import { SolutionWithLatestIterationChannel } from '@/channels/solutionWithLatestIterationChannel'
import { IterationStatus } from '@/components/types'
import type {
  RealtimeFeedbackModalProps,
  ResolvedIteration,
} from '../RealTimeFeedbackModal'

const REFETCH_INTERVAL = 2000
const PENDING_STATUS = [
  IterationStatus.DELETED,
  IterationStatus.UNTESTED,
  IterationStatus.TESTING,
  IterationStatus.ANALYZING,
]

export function useGetLatestIteration({
  request,
  submission,
  solution,
  feedbackModalOpen,
}: Pick<RealtimeFeedbackModalProps, 'request' | 'submission' | 'solution'> & {
  feedbackModalOpen: boolean
}): {
  latestIteration: ResolvedIteration | undefined
  checkStatus: string
} {
  const [latestIteration, setLatestIteration] = useState<ResolvedIteration>()
  const [checkStatus, setCheckStatus] = useState('idle')

  const queryClient = useQueryClient()
  const CACHE_KEY = `editor-${solution.uuid}-feedback`

  const [queryEnabled, setQueryEnabled] = useState(false)

  const { data: resolvedData } = usePaginatedRequestQuery<{
    iteration: ResolvedIteration
  }>([CACHE_KEY], {
    ...request,
    options: {
      ...request?.options,
      refetchInterval: queryEnabled ? REFETCH_INTERVAL : false,
      staleTime: 1000,
    },
  })

  useEffect(() => {
    const { iteration } = resolvedData || {}
    if (
      iteration &&
      submission?.uuid === iteration?.submissionUuid &&
      !PENDING_STATUS.includes(iteration.status)
    ) {
      setLatestIteration(iteration)
      setCheckStatus(iteration.status)
    } else {
      setCheckStatus('loading')
      setLatestIteration(undefined)
    }
  }, [latestIteration, resolvedData, submission])

  useEffect(() => {
    const solutionChannel = new SolutionWithLatestIterationChannel(
      { uuid: solution.uuid },
      (response) => {
        queryClient.setQueryData([CACHE_KEY], { iteration: response.iteration })
      }
    )

    return () => {
      solutionChannel.disconnect()
    }
  }, [CACHE_KEY, queryClient, solution])

  useEffect(() => {
    if (checkStatus === 'loading' && feedbackModalOpen) {
      setQueryEnabled(true)
    } else setQueryEnabled(false)
  }, [checkStatus, feedbackModalOpen, latestIteration])

  return { latestIteration, checkStatus }
}
