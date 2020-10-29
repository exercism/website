import React from 'react'
import { useRequestQuery } from '../../hooks/request-query'
import { Loading } from '../common/Loading'

type UserSummaryData = {
  name: string
  handle: string
  avatarUrl: string
  bio?: string
  location?: string
  reputation: {
    total: number
    tooling: number
  }
  badges: {
    count: number
    latest: string[]
  }
}

export function UserSummary({
  endpoint,
  styles,
}: {
  endpoint: string
  styles?: React.CSSProperties
}) {
  const request = { endpoint: endpoint, options: {} }
  const { isLoading, isError, isSuccess, data } = useRequestQuery<
    UserSummaryData
  >('user-summary-tooltip', request)

  return (
    <div className="c-tooltip c-user-summary-tooltip" style={styles}>
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
            <div>{data.name}</div>
            <div>@{data.handle}</div>
            <div>
              Reputation {data.reputation.total}, {data.reputation.tooling} for
              tooling
            </div>
            {data.bio && <div>{data.bio}</div>}
            {data.location && <div>{data.location}</div>}
            <div>{data.badges.count} badges collected</div>
            <div>{data.badges.latest.join(', ')}</div>
          </div>
        ))}
    </div>
  )
}
