import React from 'react'
import { Contribution as ContributionProps } from '../../types'
import { TrackIcon, Reputation, GraphicalIcon, Pagination } from '../../common'
import { fromNow } from '../../../utils/time'
import { FetchingBoundary } from '../../FetchingBoundary'
import { ResultsZone } from '../../ResultsZone'
import { useIsMounted } from 'use-is-mounted'
import { useList } from '../../../hooks/use-list'
import { usePaginatedRequestQuery, Request } from '../../../hooks/request-query'

type PaginatedResult = {
  results: readonly ContributionProps[]
  meta: {
    currentPage: number
    totalCount: number
    totalPages: number
  }
}

const DEFAULT_ERROR = new Error('Unable to load maintaining contributions')

export const MaintainingContributionsList = ({
  request: initialRequest,
}: {
  request: Request
}): JSX.Element => {
  const isMountedRef = useIsMounted()

  const { request, setPage } = useList(initialRequest)
  const {
    status,
    resolvedData,
    latestData,
    isFetching,
    error,
  } = usePaginatedRequestQuery<PaginatedResult, Error | Response>(
    [request.endpoint, request.query],
    request,
    isMountedRef
  )

  return (
    <ResultsZone isFetching={isFetching}>
      <FetchingBoundary
        error={error}
        status={status}
        defaultError={DEFAULT_ERROR}
      >
        {resolvedData ? (
          <React.Fragment>
            <div className="maintaining">
              {resolvedData.results.map((contribution) => (
                <Contribution key={contribution.id} {...contribution} />
              ))}
            </div>
            <Pagination
              disabled={latestData === undefined}
              current={request.query.page}
              total={resolvedData.meta.totalPages}
              setPage={setPage}
            />
          </React.Fragment>
        ) : null}
      </FetchingBoundary>
    </ResultsZone>
  )
}

const Contribution = ({
  value,
  text,
  iconUrl,
  internalUrl,
  externalUrl,
  awardedAt,
  track,
}: ContributionProps): JSX.Element => {
  const url = internalUrl || externalUrl
  const linkIcon = url === internalUrl ? 'chevron-right' : 'external-link'
  const parsedText = text
    .replace(/^You reviewed/, 'Reviewed')
    .replace(/^You merged/, 'Merged')

  return (
    <a href={url} className="reputation-token">
      <img
        alt=""
        role="presentation"
        src={iconUrl}
        className="c-icon primary-icon"
      />
      <div className="info">
        <div
          className="title"
          dangerouslySetInnerHTML={{
            __html: parsedText,
          }}
        />
        <div className="extra">
          {track ? (
            <div className="exercise">
              in
              <TrackIcon
                iconUrl={track.iconUrl}
                title={track.title}
                className="primary-icon"
              />
              <div className="name">{track.title}</div>
            </div>
          ) : (
            <div className="generic">Generic</div>
          )}
          <time dateTime={awardedAt}>{fromNow(awardedAt)}</time>
        </div>
      </div>
      <Reputation value={`+ ${value}`} type="primary" size="small" />
      <GraphicalIcon icon={linkIcon} className="action-button" />
    </a>
  )
}
