import React from 'react'
import { useIsMounted } from 'use-is-mounted'
import { useRequestQuery } from '../../hooks/request-query'
import { fromNow } from '../../utils/time'
import { Loading, Avatar, GraphicalIcon, Icon, Reputation } from '../common'
import { Student as StudentData } from '../types'
import pluralize from 'pluralize'

export type APIResponse = {
  student: StudentData
}

export function Student({
  endpoint,
  styles,
}: {
  endpoint: string
  styles?: React.CSSProperties
}): JSX.Element {
  const request = { endpoint: endpoint, options: {} }
  const isMountedRef = useIsMounted()
  const { isLoading, isError, isSuccess, data } = useRequestQuery<APIResponse>(
    'mentored-student-tooltip',
    request,
    isMountedRef
  )

  return (
    <div className="c-student-tooltip" style={styles}>
      {isLoading && <Loading />}
      {isError && <p>Something went wrong</p>}
      {isSuccess &&
        (data === undefined ? null : (
          <>
            <div className="header">
              <Avatar src={data.student.avatarUrl} />
              <div className="info">
                <div className="handle">{data.student.handle}</div>
                {data.student.name ? (
                  <div className="name">{data.student.name}</div>
                ) : null}
              </div>
              <Reputation
                value={data.student.reputation}
                type="primary"
                size="small"
              />
            </div>

            {data.student.trackObjectives ? (
              <div className="track-objectives">
                <h3>Track objectives</h3>
                <p>{data.student.trackObjectives}</p>
              </div>
            ) : null}

            {data.student.location ? (
              <div className="location">
                <Icon icon="location" alt="Located in" />
                {data.student.location}
              </div>
            ) : null}

            {data.student.numTotalDiscussions > 0 ? (
              <div className="previous-sessions">
                Mentored <strong>{data.student.numTotalDiscussions}</strong>{' '}
                {pluralize('time', data.student.numTotalDiscussions)}
                {data.student.numPreviousSessions > 0 ? (
                  <>
                    , of which{' '}
                    <strong>{data.student.numPreviousSessions}</strong>{' '}
                    {pluralize('time', data.student.numPreviousSessions)} by you
                  </>
                ) : (
                  <>
                    {' '}
                    but <strong>never</strong> by you
                  </>
                )}
              </div>
            ) : (
              <div className="previous-sessions">
                This will be their <strong>first</strong> mentoring session
              </div>
            )}

            {data.student.isFavorited ? (
              <div className="favorited">
                <GraphicalIcon icon="gold-star" />
                Favorited
              </div>
            ) : null}
          </>
        ))}
    </div>
  )
}
