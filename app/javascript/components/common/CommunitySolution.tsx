import React from 'react'
import { GraphicalIcon, Avatar, Icon } from '../common'
import { CommunitySolution as CommunitySolutionProps } from '../types'
import { useHighlighting } from '../../utils/highlight'
import { fromNow } from '../../utils/time'
import { ExerciseIcon } from './ExerciseIcon'
import { ProcessingStatusSummary } from './ProcessingStatusSummary'

const PublishDetails = ({ solution }: { solution: CommunitySolutionProps }) => {
  return (
    <>
      <time dateTime={solution.publishedAt}>{`Published ${fromNow(
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
  context: 'mentoring' | 'profile' | 'exercise'
}): JSX.Element => {
  const snippetRef = useHighlighting<HTMLPreElement>()

  const url =
    context === 'mentoring'
      ? solution.links.privateUrl
      : solution.links.publicUrl

  return (
    <a href={url} className="c-community-solution">
      <header className="--header">
        {context === 'mentoring' ? (
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
          <div className="--title">
            {context === 'mentoring'
              ? 'Your Solution'
              : `${solution.author.handle}'s solution`}
          </div>
          <div className="--track-title">
            to {solution.exercise.title} in {solution.track.title}
          </div>
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
