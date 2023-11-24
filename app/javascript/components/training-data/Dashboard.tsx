import React from 'react'
import { TaggableCodeList } from './dashboard/TaggableCodeList'
import { ResultsZone } from '../ResultsZone'
import { DashboardProps } from './dashboard/Dashboard.types'
import { DashboardTabs } from './dashboard/DashboardTabs'
import { DashboardHeader } from './dashboard/DashboardHeader'
import { useDashboard } from './dashboard/useDashboard'

export default function Dashboard({
  tracks,
  trainingDataRequest,
  statuses,
}: DashboardProps): JSX.Element {
  const {
    request,
    setStatus,
    isFetching,
    resolvedData,
    status,
    refetch,
    setPage,
    criteria,
    setCriteria,
    setTrack,
  } = useDashboard({ trainingDataRequest })

  return (
    <div className="c-training-data">
      <DashboardTabs
        currentStatus={request.query.status}
        setStatus={setStatus}
        statuses={statuses}
      />
      <div className="container overflow-hidden">
        <DashboardHeader
          request={request}
          criteria={criteria}
          setCriteria={setCriteria}
          tracks={tracks}
          setTrack={setTrack}
        />
        <ResultsZone isFetching={isFetching}>
          <TaggableCodeList
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
