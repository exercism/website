// i18n-namespace: components/common/CommunitySolution.tsx
import React from 'react'
import { shortFromNow } from '@/utils/time'
import { useHighlighting } from '@/utils/highlight'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { ExerciseIcon } from './ExerciseIcon'
import { ProcessingStatusSummary } from './ProcessingStatusSummary'
import { GraphicalIcon, Avatar, Icon } from '../common'
import { Outdated } from './exercise-widget/info/Outdated'
import { GenericTooltip } from '../misc/ExercismTippy'
import {
  type CommunitySolution as CommunitySolutionProps,
  type CommunitySolutionContext,
  SubmissionTestsStatus,
} from '../types'

const PublishDetails = ({ solution }: { solution: CommunitySolutionProps }) => {
  const { t } = useAppTranslation('components/common/CommunitySolution.tsx')
  return (
    <>
      <time dateTime={solution.publishedAt}>
        {t('communitySolution.published', {
          time: shortFromNow(solution.publishedAt),
        })}
      </time>
      <div className="--counts">
        {solution.representationNumPublishedSolutions ? (
          <div
            className="--count"
            title={t('communitySolution.numTimesPublishedSimilar')}
          >
            <GraphicalIcon icon="upload" />
            <div className="--num">
              {solution.representationNumPublishedSolutions.toLocaleString()}
            </div>
          </div>
        ) : null}
        {solution.numLoc ? (
          <div
            className="--count"
            title={t('communitySolution.numLinesOfCode')}
          >
            <GraphicalIcon icon="loc" />
            <div className="--num">{solution.numLoc.toLocaleString()}</div>
          </div>
        ) : null}
        <div className="--count" title={t('communitySolution.numTimesStarred')}>
          <GraphicalIcon icon="star" />
          <div className="--num">{solution.numStars.toLocaleString()}</div>
        </div>
        {solution.numComments &&
        !solution.representationNumPublishedSolutions ? (
          <div
            className="--count"
            title={t('communitySolution.numTimesCommented')}
          >
            <GraphicalIcon icon="comment" />
            <div className="--num">{solution.numComments.toLocaleString()}</div>
          </div>
        ) : null}
      </div>
    </>
  )
}

const ProcessingStatus = ({
  solution,
}: {
  solution: CommunitySolutionProps
}) => {
  const { t } = useAppTranslation('components/common/CommunitySolution.tsx')
  if (
    solution.publishedIterationHeadTestsStatus === SubmissionTestsStatus.PASSED
  ) {
    return (
      <GenericTooltip content={t('communitySolution.correctlySolvesLatest')}>
        <div>
          <Icon
            icon="golden-check"
            alt={t('communitySolution.passesLatestTests')}
            className="passed-up-to-date-tests"
          />
        </div>
      </GenericTooltip>
    )
  }

  if (
    solution.publishedIterationHeadTestsStatus ===
      SubmissionTestsStatus.FAILED ||
    solution.publishedIterationHeadTestsStatus === SubmissionTestsStatus.ERRORED
  ) {
    return (
      <GenericTooltip content={t('communitySolution.doesNotFullySolveLatest')}>
        <div>
          <Icon
            icon="cross-circle"
            alt={t('communitySolution.doesNotFullySolveLatest')}
            className="failed-up-to-date-tests"
          />
        </div>
      </GenericTooltip>
    )
  }

  return (
    <>
      {solution.isOutOfDate ? (
        <GenericTooltip content={t('communitySolution.solvedAgainstOlder')}>
          <div>
            <Outdated />
          </div>
        </GenericTooltip>
      ) : null}
      <ProcessingStatusSummary iterationStatus={solution.iterationStatus} />
    </>
  )
}

export default function CommunitySolution({
  solution,
  context,
}: {
  solution: CommunitySolutionProps
  context: CommunitySolutionContext
}): JSX.Element {
  const { t } = useAppTranslation('components/common/CommunitySolution.tsx')
  const snippetRef = useHighlighting<HTMLPreElement>()

  const url =
    context === 'mentoring'
      ? solution.links.privateIterationsUrl
      : solution.links.publicUrl

  return (
    <a href={url} className="c-community-solution">
      <header className="--header">
        {context === 'profile' ? (
          <ExerciseIcon
            iconUrl={solution.exercise.iconUrl}
            title={solution.exercise.title}
          />
        ) : (
          <Avatar
            handle={solution.author.handle}
            src={solution.author.avatarUrl}
          />
        )}

        <div className="--info">
          {context == 'mentoring' ? (
            <>
              <div className="--title">
                {t('communitySolution.yourSolution')}
              </div>
              <div className="--subtitle">
                {t('communitySolution.toExerciseInTrack', {
                  exercise: solution.exercise.title,
                  track: solution.track.title,
                })}
              </div>
            </>
          ) : context == 'profile' ? (
            <>
              <div className="--title">{solution.exercise.title}</div>
              <div className="--subtitle">
                {t('communitySolution.inTrack', {
                  track: solution.track.title,
                })}
              </div>
            </>
          ) : (
            <>
              <div className="--title flex">
                {t('communitySolution.authorsSolution', {
                  handle: solution.author.handle,
                })}
              </div>
              <div className="--subtitle">
                {t('communitySolution.toExerciseInTrack', {
                  exercise: solution.exercise.title,
                  track: solution.track.title,
                })}
              </div>
            </>
          )}
        </div>

        <ProcessingStatus solution={solution} />
      </header>
      <pre ref={snippetRef}>
        <code className={`language-${solution.track.highlightjsLanguage}`}>
          {solution.snippet}
        </code>
      </pre>
      <footer className="--footer">
        {solution.publishedAt ? (
          <PublishDetails solution={solution} />
        ) : (
          <>
            <div className="not-published">
              {t('communitySolution.notPublished')}
            </div>
            <div className="--counts">
              <div className="--count">
                <GraphicalIcon icon="loc" />
                <div className="--num">{solution.numLoc}</div>
              </div>
            </div>
          </>
        )}
      </footer>
    </a>
  )
}
