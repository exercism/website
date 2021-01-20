import React from 'react'
import { useIsMounted } from 'use-is-mounted'
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
}): JSX.Element {
  const request = { endpoint: endpoint, options: {} }
  const isMountedRef = useIsMounted()
  const { isLoading, isError, isSuccess, data } = useRequestQuery<
    MentoredStudentData
  >('mentored-student-tooltip', request, isMountedRef)

  return (
    <div className="c-tooltip c-mentored-student-tooltip" style={styles}>
      {isLoading && <Loading />}
      {isError && <p>Something went wrong</p>}
      {isSuccess &&
        (data === undefined ? null : (
          <div>
            <img
              style={{ width: 100 }}
              src={data.avatarUrl}
              alt={`avatar for ${data.handle}`}
            />
            <div>{data.handle}</div>
            <div>{data.isStarred.toString()}</div>
            <div>{data.haveMentoredPreviously.toString()}</div>
            <div>{data.status}</div>
            <div>{fromNow(data.updatedAt)}</div>
          </div>
        ))}
    </div>
  )
}
