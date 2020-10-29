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
            <header>
              {/* TODO: Use rounded_bg_img helper */}
              <div
                className="c-rounded-bg-img"
                style={{ backgroundImage: `url(${data.avatarUrl})` }}
                aria-title={`avatar for ${data.handle}`}
              />
              <div className="identifier">
                <h4>{data.name}</h4>
                <div className="handle">@{data.handle}</div>
              </div>
              {/* TODO: Use reputation helper */}
              <div
                className="c-reputation"
                aria-label={`${data.reputation.total} reputation`}
              >
                <svg role="img" className="icon ">
                  <title>Reputation</title>
                  <use href="#reputation"></use>
                </svg>
                {data.reputation.total}
              </div>
            </header>
            {data.bio && <div className="bio">{data.bio}</div>}
            {data.location && (
              <div className="location">
                {/* TODO: Use icon helper */}
                <svg role="img" className="icon" aria-label="Located in">
                  <use href="#location"></use>
                </svg>
                {data.location}
              </div>
            )}
            {/*<div>{data.badges.count} badges collected</div>
            <div>{data.badges.latest.join(', ')}</div>*/}
          </div>
        ))}
    </div>
  )
}
