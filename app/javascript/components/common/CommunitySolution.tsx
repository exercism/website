import React from 'react'
import { GraphicalIcon, Avatar, Icon } from '../common'
import {
  MentorSessionTrack as Track,
  MentorSessionExercise as Exercise,
  CommunitySolution as CommunitySolutionProps,
} from '../types'
import { useHighlighting } from '../../utils/highlight'
import { fromNow } from '../../utils/time'

const PublishDetails = ({ solution }: { solution: CommunitySolutionProps }) => {
  return (
    <>
      {/* TODO: Add the datetime attribute thing */}
      <time>{`Published ${fromNow(solution.publishedAt)}`}</time>
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

/* TODO: Pass an context into this component. In different contexts we render different images here */
/* It can be mentoring, profile or exercise */
export const CommunitySolution = ({
  solution,
  track,
  exercise,
}: {
  solution: CommunitySolutionProps
  track: Track
  exercise: Exercise
}): JSX.Element => {
  const snippetRef = useHighlighting<HTMLPreElement>()

  /* TODO: If context == "mentoring" use privateUrl else use publicUrl */
  const url = solution.links.publicUrl

  return (
    <a href={url} className="c-community-solution">
      <header className="--header">
        {/* TODO: If context == "profile" || "exercise" */}
        <Avatar
          handle={solution.author.handle}
          src={solution.author.avatarUrl}
        />
        {/* TODO: else (context == "profile") use ExerciseIcon */}

        <div className="--info">
          <div className="--title">
            {/* TODO: if context == "mentoring" */}
            Your Solution
            {/* TODO: else "${solution.author.name's} solution" */}
          </div>
          <div className="--track-title">
            to {exercise.title} in {track.title}
          </div>
        </div>

        {/* TODO: If solution.out_of_date? */}
        <div className="out-of-date">
          <Icon
            icon="warning"
            alt="This solution has not been tested against the latest version of this exercise"
          />
        </div>

        {/* TODO: Use the component for this that's used on iteration summary etc. Make it common. */}
        <div className="c-iteration-processing-status --passed">
          <div className="--dot" />
        </div>
      </header>
      <pre ref={snippetRef}>
        <code dangerouslySetInnerHTML={{ __html: solution.snippet }} />
      </pre>
      <footer className="--footer">
        {solution.publishedAt ? (
          <PublishDetails solution={solution} />
        ) : (
          <>
            <div className="not-published">Not published</div>
            <div className="--counts">
              {/* This is in this file twice - you might want to DRY it */}
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
