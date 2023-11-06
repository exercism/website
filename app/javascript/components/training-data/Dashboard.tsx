import React from 'react'
import { TaggableCodeList } from './dashboard/TaggableCodeList'
import { ResultsZone } from '../ResultsZone'
import { DashboardProps } from './dashboard/Dashboard.types'
import { DashboardTabs } from './dashboard/DashboardTabs'
import { DashboardHeader } from './dashboard/DashboardHeader'
import { useDashboard } from './dashboard/useDashboard'

export default function Dashboard({
  tracksRequest,
  trainingDataRequest,
  statuses,
}: DashboardProps): JSX.Element {
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
        statuses={statuses}
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
