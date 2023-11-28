import React from 'react'
import { Student } from '../types'
import { useRequestQuery } from '../../hooks/request-query'
import { FetchingBoundary } from '../FetchingBoundary'
import { Avatar, GraphicalIcon, Icon, Reputation } from '../common'
import pluralize from 'pluralize'
import { StudentTooltipSkeleton } from '../common/skeleton/skeletons/StudentTooltipSkeleton'

const DEFAULT_ERROR = new Error('Unable to load information')

const StudentTooltip = React.forwardRef<
  HTMLDivElement,
  React.HTMLProps<HTMLDivElement> & { endpoint: string }
>(({ endpoint, ...props }, ref) => {
  const { data, error, status } = useRequestQuery<{ student: Student }>(
    [endpoint],
    { endpoint: endpoint, options: {} }
  )

  return (
    <div className="c-student-tooltip" {...props} ref={ref}>
      <FetchingBoundary
        status={status}
        error={error}
        defaultError={DEFAULT_ERROR}
        LoadingComponent={() => <StudentTooltipSkeleton />}
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

export default StudentTooltip
