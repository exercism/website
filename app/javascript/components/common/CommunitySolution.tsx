import React from 'react'
import { GraphicalIcon, Avatar, Icon } from '../common'
import {
  CommunitySolution as CommunitySolutionProps,
  CommunitySolutionContext,
} from '../types'
import { useHighlighting } from '../../utils/highlight'
import { shortFromNow } from '../../utils/time'
import { ExerciseIcon } from './ExerciseIcon'
import { ProcessingStatusSummary } from './ProcessingStatusSummary'

const PublishDetails = ({ solution }: { solution: CommunitySolutionProps }) => {
  return (
    <>
      <time dateTime={solution.publishedAt}>{`Published ${shortFromNow(
        solution.publishedAt
      )}`}</time>
      <div className="--counts">
        <div className="--count">
          <GraphicalIcon icon="loc" />
          <div className="--num">{solution.numLoc}</div>
        </div>
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
      ? solution.links.privateUrl
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
              <div className="--title"> Your Solution </div>
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
              <div className="--title">{solution.author.handle}'s solution</div>
              <div className="--subtitle">
                to {solution.exercise.title} in {solution.track.title}
              </div>
            </>
          )}
        </div>

        {solution.isOutOfDate ? (
          <div className="out-of-date">
            <Icon
              icon="warning"
              alt="This solution has not been tested against the latest version of this exercise"
            />
          </div>
        ) : null}

        <ProcessingStatusSummary iterationStatus={solution.iterationStatus} />
      </header>
      <pre ref={snippetRef} className={solution.track.highlightjsLanguage}>
        <code dangerouslySetInnerHTML={{ __html: solution.snippet }} />
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
