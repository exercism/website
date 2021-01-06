import React, { useState } from 'react'
import { MentoringPanelList } from './mentor-discussion/MentoringPanelList'
import { IterationsList } from './mentor-discussion/IterationsList'
import { BackButton } from './mentor-discussion/BackButton'

type Links = {
  scratchpad: string
  exercise: string
}

export type Iteration = {
  idx: number
  numComments: number
  unread: boolean
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
        <BackButton url={links.exercise} />
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
