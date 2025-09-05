import React from 'react'
import { fromNow } from '../../utils/time'
import { GraphicalIcon, TrackIcon, ExerciseIcon, Icon } from '../common'
import { GenericTooltip } from '../misc/ExercismTippy'
import pluralize from 'pluralize'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export type SolutionProps = {
  uuid: string
  privateUrl: string
  status: string
  publishedIterationHeadTestsStatus: string
  numViews?: number
  numStars: number
  numComments: number
  numIterations: number
  numLoc?: string
  lastIteratedAt: string
  isOutOfDate: boolean
  exercise: {
    title: string
    iconUrl: string
  }
  track: {
    title: string
    iconUrl: string
  }
}

export const Solution = ({
  privateUrl,
  status,
  publishedIterationHeadTestsStatus,
  numViews,
  numStars,
  numComments,
  numIterations,
  numLoc,
  lastIteratedAt,
  exercise,
  track,
  isOutOfDate,
}: SolutionProps): JSX.Element => {
  const { t } = useAppTranslation()
  return (
    <a href={privateUrl} className="solution">
      <div className="main">
        <div className="exercise">
          <ExerciseIcon iconUrl={exercise.iconUrl} />
          <div className="info">
            <div className="flex items-center mb-8">
              <div className="exercise-title">{exercise.title}</div>

              {isOutOfDate ? (
                <GenericTooltip
                  content={t(
                    'solution.thereIsANewerVersionOfTheExerciseVisitTheExercisePageToUpgrade'
                  )}
                >
                  <div>
                    <Icon
                      icon="warning"
                      alt={t(
                        'solution.thereIsANewerVersionOfTheExerciseVisitTheExercisePageToUpgrade'
                      )}
                      className="--out-of-date"
                    />
                  </div>
                </GenericTooltip>
              ) : null}

              {publishedIterationHeadTestsStatus === 'passed' ? (
                <Icon
                  icon="golden-check"
                  alt={t('solution.passesTestsOfTheLatestVersionOfTheExercise')}
                  className="head-tests-status --passed"
                />
              ) : publishedIterationHeadTestsStatus === 'failed' ||
                publishedIterationHeadTestsStatus === 'errored' ? (
                <GenericTooltip
                  content={t(
                    'solution.thisSolutionFailsTheTestsOfTheLatestVersionOfTheExerciseTryUpdatingTheExerciseAndCheckingItLocallyOrInTheOnlineEditor'
                  )}
                >
                  <div>
                    <Icon
                      icon="cross-circle"
                      alt={t(
                        'solution.failedTestsOfTheLatestVersionOfTheExercise'
                      )}
                      className="head-tests-status --failed"
                    />
                  </div>
                </GenericTooltip>
              ) : null}
            </div>
            <div className="extra">
              <div className="track">
                <Trans
                  ns="components/journey"
                  i18nKey="solution.inTrack"
                  values={{ track: track.title }}
                  components={[
                    <TrackIcon iconUrl={track.iconUrl} title={track.title} />,
                    <div className="track-title" />,
                  ]}
                />
              </div>
              {status === 'completed' ? (
                <div className="status">
                  <GraphicalIcon icon="completed-check-circle" />
                  {t('solution.completed')}
                </div>
              ) : status === 'published' ? (
                <div className="status">
                  <GraphicalIcon icon="completed-check-circle" />
                  {t('solution.published')}
                </div>
              ) : (
                <></>
              )}
            </div>
          </div>
        </div>
        <div className="stats">
          <div className="stat">
            <GraphicalIcon icon="iteration" />
            {t('solution.iterations', { count: numIterations })}
          </div>
          {numLoc ? (
            <div className="stat">
              <GraphicalIcon icon="loc" />
              {t('solution.lines', { numLoc: numLoc })}
            </div>
          ) : null}
          {numViews ? (
            <div className="stat">
              <GraphicalIcon icon="views" />
              {numViews}{' '}
              {t('solution.views', {
                numViews: numViews,
                viewLabel: pluralize('view', numViews),
              })}
            </div>
          ) : null}
        </div>
        {lastIteratedAt ? (
          <time className="iterated-at" dateTime={lastIteratedAt}>
            {t('solution.lastSubmitted', {
              lastIteratedAt: fromNow(lastIteratedAt),
            })}
          </time>
        ) : null}
      </div>
      <div className="counts">
        <div className="count">
          <GraphicalIcon icon="star" />
          <div className="num">{numStars}</div>
        </div>
        <div className="count">
          <GraphicalIcon icon="comment" />
          <div className="num">{numComments}</div>
        </div>
      </div>
    </a>
  )
}
