import { useState, useEffect } from 'react'
import { usePaginatedRequestQuery } from '@/hooks/request-query'
import { useHistory, removeEmpty } from '@/hooks/use-history'
import { useList } from '@/hooks/use-list'
import type {
  TrainingDataRequest,
  TrainingDataRequestAPIResponse,
  TrainingDataStatus,
} from './Dashboard.types'

export type useDashboardReturnType = ReturnType<typeof useDashboard>

export function useDashboard({
  trainingDataRequest,
}: {
  trainingDataRequest: TrainingDataRequest
}) {
  const [criteria, setCriteria] = useState(trainingDataRequest.query?.criteria)
  const {
    request,
    setCriteria: setRequestCriteria,
    setOrder,
    setPage,
    setQuery,
  } = useList(trainingDataRequest)
  const {
    status,
    data: resolvedData,
    isFetching,
    refetch,
  } = usePaginatedRequestQuery<TrainingDataRequestAPIResponse>(
    ['ml-trainer-list', request.endpoint, request.query],
    request
  )

  useEffect(() => {
    const handler = setTimeout(() => {
      if (criteria === undefined || criteria === null) return
      setRequestCriteria(criteria)
    }, 200)

    return () => {
      clearTimeout(handler)
    }
  }, [setRequestCriteria, criteria])

  useHistory({ pushOn: removeEmpty(request.query) })

  const setTrack = (trackSlug: string | null) => {
    setQuery({ ...request.query, trackSlug, page: undefined })
  }

  const setStatus = (status: TrainingDataStatus) => {
    setQuery({ ...request.query, status, page: undefined })
  }

  return {
    request,
    criteria,
    setCriteria,
    setOrder,
    setPage,
    status,
    resolvedData,
    isFetching,
    refetch,
    refetchType: typeof refetch,
    setTrack,
    setStatus,
  }
}
