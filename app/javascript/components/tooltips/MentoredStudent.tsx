import React from 'react'
import { useRequestQuery } from '../../hooks/request-query'
import { fromNow } from '../../utils/time'
import { Loading } from '../common/Loading'

type MentoredStudentData = {
  avatarUrl: string
  handle: string
  isStarred: boolean
  haveMentoredPreviously: boolean
  status: string
  updatedAt: string
}

export function MentoredStudent({
  endpoint,
  styles,
}: {
  endpoint: string
  styles?: React.CSSProperties
}) {
  const request = { endpoint: endpoint, options: {} }
  const { isLoading, isError, isSuccess, data } = useRequestQuery<
    MentoredStudentData
  >('student-tooltip', request)

  return (
    <div className="c-tooltip c-mentored-student-tooltip" style={styles}>
      {isLoading && <Loading />}
      {isError && <p>Something went wrong</p>}
      {isSuccess &&
        (data === undefined ? null : <MentoredStudentSummary {...data} />)}
    </div>
  )
}

function MentoredStudentSummary({
  avatarUrl,
  handle,
  isStarred,
  haveMentoredPreviously,
  status,
  updatedAt,
}: MentoredStudentData) {
  return (
    <div>
      <img
        style={{ width: 100 }}
        src={avatarUrl}
        alt={`avatar for ${handle}`}
      />
      <div>{handle}</div>
      <div>{isStarred}</div>
      <div>{handle}</div>
      <div>{isStarred.toString()}</div>
      <div>{haveMentoredPreviously.toString()}</div>
      <div>{status}</div>
      <div>{fromNow(updatedAt)}</div>
    </div>
  )
}
