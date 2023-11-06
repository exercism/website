import React, { useState, useEffect } from 'react'
import { TaggableCodeList } from './dashboard/TaggableCodeList'
import { TextFilter } from '@/components/mentoring/TextFilter'
import { Sorter } from '@/components/mentoring/Sorter'
import { TrackFilter } from '@/components/mentoring/inbox/TrackFilter'
import {
  usePaginatedRequestQuery,
  type Request as BaseRequest,
  Request,
} from '@/hooks/request-query'
import { useHistory, removeEmpty } from '@/hooks/use-history'
import { useList } from '@/hooks/use-list'
import { ResultsZone } from '../ResultsZone'
import {
  TrainingDataRequest,
  TrainingDataStatus,
} from './dashboard/Dashboard.types'
import { SolutionProps } from '../journey/Solution'
import { DashboardTabs } from './dashboard/DashboardTabs'
import { DashboardHeader } from './dashboard/DashboardHeader'
import { useDashboard } from './dashboard/useDashboard'

export default function Dashboard({
  tracksRequest,
  trainingDataRequest,
}: {
  tracksRequest: Request
  trainingDataRequest: TrainingDataRequest
}): JSX.Element {
  const {
    request,
    setStatus,
    isFetching,
    latestData,
    resolvedData,
    status,
    refetch,
    setPage,
    criteria,
    setCriteria,
    setTrack,
    setOrder,
  } = useDashboard({ trainingDataRequest })

  return (
    <div className="c-mentor-inbox">
      <DashboardTabs
        currentStatus={request.query.status}
        setStatus={setStatus}
      />
      <div className="container">
        <DashboardHeader
          criteria={criteria}
          setCriteria={setCriteria}
          request={request}
          tracksRequest={tracksRequest}
          setTrack={setTrack}
          setOrder={setOrder}
          setPage={setPage}
        />
        <ResultsZone isFetching={isFetching}>
          <TaggableCodeList
            latestData={latestData}
            resolvedData={resolvedData}
            status={status}
            refetch={refetch}
            setPage={setPage}
          />
        </ResultsZone>
      </div>
    </div>
  )
}
