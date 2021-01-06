import React, { useState } from 'react'
import { MentoringPanelList } from './MentoringPanelList'
import { IterationsList } from './IterationsList'

type Links = {
  posts: string
  scratchpad: string
}

export type Iteration = {
  idx: number
  numComments: number
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
        <IterationsList
          iterations={iterations}
          onClick={setCurrentIteration}
          current={currentIteration}
        />
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
