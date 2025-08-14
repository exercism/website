import React from 'react'
import { useTranslation, Trans } from 'react-i18next'
import { Student } from '../types'
import { useRequestQuery } from '../../hooks/request-query'
import { FetchingBoundary } from '../FetchingBoundary'
import { Avatar, GraphicalIcon, Icon, Reputation } from '../common'
import { StudentTooltipSkeleton } from '../common/skeleton/skeletons/StudentTooltipSkeleton'

const DEFAULT_ERROR = new Error('Unable to load information')

const StudentTooltip = React.forwardRef<
  HTMLDivElement,
  React.HTMLProps<HTMLDivElement> & { endpoint: string }
>(({ endpoint, ...props }, ref) => {
  const { t } = useTranslation('components/tooltips/student-tooltip')
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
                <h3>{t('trackObjectivesTitle')}</h3>
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
                <Trans
                  ns="components/tooltips/student-tooltip"
                  i18nKey={previousSessionsKey(
                    data.student.numTotalDiscussions,
                    data.student.numDiscussionsWithMentor
                  )}
                  values={{
                    count: data.student.numTotalDiscussions,
                    total: data.student.numTotalDiscussions,
                    withMentor: data.student.numDiscussionsWithMentor,
                  }}
                  components={{ strong: <strong /> }}
                />
              </div>
            ) : (
              <div className="previous-sessions">
                <Trans
                  i18nKey="firstSession"
                  ns="components/tooltips/student-tooltip"
                  components={{ strong: <strong /> }}
                />
              </div>
            )}

            {data.student.isFavorited ? (
              <div className="favorited">
                <GraphicalIcon icon="gold-star" />
                {t('favorited')}
              </div>
            ) : null}
          </>
        ) : (
          <span>{t('unableToLoad')}</span>
        )}
      </FetchingBoundary>
    </div>
  )
})

function previousSessionsKey(total: number, withMentor: number): string {
  if (withMentor === 0) {
    return 'previousSessions.never'
  }
  const totalPart = total === 1 ? 'one' : 'other'
  const withMentorPart = withMentor === 1 ? 'one' : 'other'
  return `previousSessions.some_${totalPart}_${withMentorPart}`
}

export default StudentTooltip
