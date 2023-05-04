import React from 'react'
import { useHighlighting, shortFromNow } from '@/utils'
import { ExerciseIcon } from './ExerciseIcon'
import { ProcessingStatusSummary } from './ProcessingStatusSummary'
import { HandleWithFlair } from './HandleWithFlair'
import { GraphicalIcon, Avatar, Icon } from '../common'
import { Outdated } from './exercise-widget/info/Outdated'
import { GenericTooltip } from '../misc/ExercismTippy'
import {
  type CommunitySolution as CommunitySolutionProps,
  type CommunitySolutionContext,
  SubmissionTestsStatus,
} from '../types'

const PublishDetails = ({ solution }: { solution: CommunitySolutionProps }) => {
  return (
    <>
      <time dateTime={solution.publishedAt}>{`Published ${shortFromNow(
        solution.publishedAt
      )}`}</time>
      <div className="--counts">
        {solution.numLoc ? (
          <div className="--count">
            <GraphicalIcon icon="loc" />
            <div className="--num">{solution.numLoc}</div>
          </div>
        ) : null}
        <div className="--count">
          <Icon icon="star" alt="Number of times solution has been stared" />
          <div className="--num">{solution.numStars}</div>
        </div>
        <div className="--count">
          <Icon
            icon="comment"
            alt="Number of times solution has been commented on"
          />
          <div className="--num">{solution.numComments}</div>
        </div>
      </div>
    </>
  )
}

const ProcessingStatus = ({
  solution,
}: {
  solution: CommunitySolutionProps
}) => {
  if (
    solution.publishedIterationHeadTestsStatus === SubmissionTestsStatus.PASSED
  ) {
    return (
      <GenericTooltip content="This solution correctly solves the latest version of this exercise">
        <div>
          <Icon
            icon="golden-check"
            alt="This solution passes the tests of the latest version of this exercise"
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
      <GenericTooltip content="This solution does not fully solve the latest version of this exercise">
        <div>
          <Icon
            icon="cross-circle"
            alt="This solution does not fully solve the latest version of this exercise"
            className="failed-up-to-date-tests"
          />
        </div>
      </GenericTooltip>
    )
  }

  return (
    <>
      {solution.isOutOfDate ? (
        <GenericTooltip content="This solution was solved against an older version of this exercise and may not fully solve the latest version.">
          <div>
            <Outdated />
          </div>
        </GenericTooltip>
      ) : null}
      <ProcessingStatusSummary iterationStatus={solution.iterationStatus} />
    </>
  )
}

export const CommunitySolution = ({
  solution,
  context,
}: {
  solution: CommunitySolutionProps
  context: CommunitySolutionContext
}): JSX.Element => {
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
              <div className="--title">Your Solution</div>
              <div className="--subtitle">
                to {solution.exercise.title} in {solution.track.title}
              </div>
            </>
          ) : context == 'profile' ? (
            <>
              <div className="--title">{solution.exercise.title}</div>
              <div className="--subtitle">in {solution.track.title}</div>
            </>
          ) : (
            <>
              <div className="--title flex">
                {solution.author.handle}&apos;s solution
              </div>
              <div className="--subtitle">
                to {solution.exercise.title} in {solution.track.title}
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
            <div className="not-published">Not published</div>
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
