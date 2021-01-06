import React, { useState } from 'react'
import { MentoringPanelList } from './mentor-discussion/MentoringPanelList'
import { IterationsList } from './mentor-discussion/IterationsList'
import { BackButton } from './mentor-discussion/BackButton'
import { SolutionInfo } from './mentor-discussion/SolutionInfo'

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

export type Student = {
  avatarUrl: string
  handle: string
}

export type Track = {
  title: string
  iconUrl: string
}

export type Exercise = {
  title: string
}

export const MentorDiscussion = ({
  student,
  track,
  exercise,
  links,
  discussionId,
  iterations,
}: {
  student: Student
  track: Track
  exercise: Exercise
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
        <SolutionInfo student={student} track={track} exercise={exercise} />
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
