import React from 'react'
import { useRequestQuery } from '../../hooks/request-query'
import { QueryResult } from 'react-query'
import { fromNow } from '../../utils/time'
import { Loading } from '../common/Loading'

export function Student({
  endpoint,
  styles,
}: {
  endpoint: string
  styles?: React.CSSProperties
}) {
  const request = { endpoint: endpoint }
  const { isLoading, isError, isSuccess, data } = useRequestQuery(
    'student-tooltip',
    request
  ) as QueryResult<any>

  return (
    <div className="c-tooltip c-tooltip-student" style={styles}>
      {isLoading && <Loading />}
      {isError && <p>Something went wrong</p>}
      {isSuccess && <StudentSummary {...data} />}
    </div>
  )
}

function StudentSummary({
  avatarUrl,
  handle,
  isStarred,
  haveMentoredPreviously,
  status,
  updatedAt,
}: {
  avatarUrl: string
  handle: string
  isStarred: boolean
  haveMentoredPreviously: boolean
  status: string
  updatedAt: string
}) {
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
