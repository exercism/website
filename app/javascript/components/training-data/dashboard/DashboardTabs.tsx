import React from 'react'
import { StatusTab } from '@/components/mentoring/inbox/StatusTab'
import { TrainingDataStatus, TrainingDataStatuses } from './Dashboard.types'
import { useLogger } from '@/hooks'
import { capitalize } from '@/utils/capitalize'

export function DashboardTabs({
  setStatus,
  currentStatus,
  statuses,
}: {
  setStatus: (status: TrainingDataStatus) => void
  currentStatus: TrainingDataStatus
  statuses: TrainingDataStatuses
}) {
  return (
    <div className="tabs">
      {statuses.map((status) => {
        return (
          <StatusTab<TrainingDataStatus>
            status={status}
            currentStatus={currentStatus}
            setStatus={setStatus}
          >
            {capitalize(status).replace('_', ' ')}
          </StatusTab>
        )
      })}
    </div>
  )
}
