import React from 'react'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { Avatar } from '../../common/Avatar'
import { Icon } from '../../common/Icon'
import {
  MentorSolution as MentorSolutionProps,
  Track,
  Exercise,
} from '../Discussion'
import { useHighlighting } from '../../../utils/highlight'

const PublishDetails = ({ solution }: { solution: MentorSolutionProps }) => {
  return (
    <div className="--counts">
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
  )
}

export const MentorSolution = ({
  solution,
  track,
  exercise,
}: {
  solution: MentorSolutionProps
  track: Track
  exercise: Exercise
}): JSX.Element => {
  const snippetRef = useHighlighting<HTMLDivElement>()

  return (
    <a href={solution.webUrl} className="c-published-solution">
      <header className="--header">
        <div className="--exercise">
          <Avatar
            handle={solution.mentor.handle}
            src={solution.mentor.avatarUrl}
          />

          <div className="--info">
            <div className="--exercise-title">Your Solution</div>
            <div className="--track-title">
              to {exercise.title} in {track.title}
            </div>
          </div>
          {solution.publishedAt ? <PublishDetails solution={solution} /> : null}
        </div>
      </header>
      <div ref={snippetRef}>
        <pre>
          <code dangerouslySetInnerHTML={{ __html: solution.snippet }} />
        </pre>
      </div>
      <footer className="--footer">
        <div className="locs">
          <GraphicalIcon icon="loc" />
          <div className="num">{solution.numLoc} lines</div>
        </div>
      </footer>
    </a>
  )
}
