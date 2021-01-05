import React, { useState } from 'react'
import { MentoringPanelList } from './MentoringPanelList'

type Links = {
  posts: string
  scratchpad: string
}

export type Iteration = {
  idx: number
  links: {
    posts: string
  }
}

export const MentorDiscussion = ({
  links,
  discussionId,
  iterations,
}: {
  links: Links
  discussionId: number
  iterations: Iteration[]
}): JSX.Element => {
  const [currentIteration, setCurrentIteration] = useState(
    iterations[iterations.length - 1]
  )

  return (
    <div className="c-mentor-discussion">
      <header className="discussion-header">
        <div className="iterations">
          {iterations.map((iteration) => (
            <button
              key={iteration.idx}
              type="button"
              className="iteration"
              onClick={() => setCurrentIteration(iteration)}
            >
              {iteration.idx}
            </button>
          ))}
        </div>
      </header>
      <div className="rhs">
        <MentoringPanelList
          links={links}
          discussionId={discussionId}
          iteration={currentIteration}
        />
      </div>
    </div>
  )
}
