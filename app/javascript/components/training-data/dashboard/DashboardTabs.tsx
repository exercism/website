import React from 'react'
import { StatusTab } from '@/components/mentoring/inbox/StatusTab'
import { TrainingDataStatus, TrainingDataStatuses } from './Dashboard.types'

const STATUS_MAP = {
  needs_tagging: 'Needs tagging',
  needs_checking: 'Needs checking',
  needs_checking_admin: 'Needs checking (admin)',
}

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
            key={status}
            status={status}
            currentStatus={currentStatus}
            setStatus={setStatus}
          >
            {STATUS_MAP[status]}
          </StatusTab>
        )
      })}
    </div>
  )
}
