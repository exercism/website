import React from 'react'
import { StatusTab } from '@/components/mentoring/inbox/StatusTab'
import { TrainingDataStatus } from './Dashboard.types'

export function DashboardTabs({
  setStatus,
  currentStatus,
  resolvedData,
}: {
  setStatus: (status: TrainingDataStatus) => void
  currentStatus: TrainingDataStatus
  resolvedData?: any
}) {
  return (
    <div className="tabs">
      <StatusTab<TrainingDataStatus>
        status="untagged"
        currentStatus={currentStatus}
        setStatus={setStatus}
      >
        Untagged
        {resolvedData ? (
          <div className="count">{resolvedData.meta.awaitingMentorTotal}</div>
        ) : null}
      </StatusTab>
      <StatusTab<TrainingDataStatus>
        status="machine_tagged"
        currentStatus={currentStatus}
        setStatus={setStatus}
      >
        Machine Tagged
        {resolvedData ? (
          <div className="count">{resolvedData.meta.awaitingStudentTotal}</div>
        ) : null}
      </StatusTab>
      <StatusTab<TrainingDataStatus>
        status="human_tagged"
        currentStatus={currentStatus}
        setStatus={setStatus}
      >
        Human tagged
        {resolvedData ? (
          <div className="count">{resolvedData.meta.finishedTotal}</div>
        ) : null}
      </StatusTab>
    </div>
  )
}
