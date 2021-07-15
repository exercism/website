import React, { useState, useEffect } from 'react'
import { Student, Track, SolutionForStudent } from '../types'
import { useRequestQuery } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { FetchingBoundary } from '../FetchingBoundary'

import { Loading, Avatar, GraphicalIcon, Icon, Reputation } from '../common'
import { Student as StudentData } from '../types'
import pluralize from 'pluralize'
import { fromNow } from '../../utils/time'

const DEFAULT_ERROR = new Error('Unable to load information')

const LoadingComponent = () => {
  const [isShowing, setIsShowing] = useState(false)

  useEffect(() => {
    const timer = setTimeout(() => {
      setIsShowing(true)
    }, 200)

    return () => clearTimeout(timer)
  }, [])

  return isShowing ? (
    <Icon icon="spinner" alt="Loading student data" className="--spinner" />
  ) : null
}

export const StudentTooltip = React.forwardRef<
  HTMLDivElement,
  React.HTMLProps<HTMLDivElement> & { endpoint: string; requestId: string }
>(({ endpoint, requestId, ...props }, ref) => {
  const { data, error, status } = useRequestQuery<{ student: Student }>(
    `student-tooltip-${requestId}`,
    { endpoint: endpoint, options: {} }
  )

  return (
    <div className="c-student-tooltip" {...props} ref={ref}>
      <FetchingBoundary
        status={status}
        error={error}
        defaultError={DEFAULT_ERROR}
        LoadingComponent={LoadingComponent}
      >
        {data ? (
          /* If we want the track we need to add a pivot to this,
           * and use track={data.track}*/
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
                {data.student.numDiscussionsWithMentor > 0 ? (
                  <>
                    , of which{' '}
                    <strong>{data.student.numDiscussionsWithMentor}</strong>{' '}
                    {pluralize('time', data.student.numDiscussionsWithMentor)}{' '}
                    by you
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
        ) : (
          <span>Unable to load information</span>
        )}
      </FetchingBoundary>
    </div>
  )
})
