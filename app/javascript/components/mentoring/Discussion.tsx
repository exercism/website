import React, { useState } from 'react'
import { MentoringPanelList } from './discussion/MentoringPanelList'
import { IterationsList } from './discussion/IterationsList'
import { BackButton } from './discussion/BackButton'
import { SolutionInfo } from './discussion/SolutionInfo'
import { IterationFiles } from './discussion/IterationFiles'
import { IterationHeader } from './discussion/IterationHeader'
import { MarkAsNothingToDoButton } from './discussion/MarkAsNothingToDoButton'

export type Links = {
  scratchpad: string
  exercise: string
  markAsNothingToDo?: string
}

export type Iteration = {
  idx: number
  numComments: number
  unread: boolean
  createdAt: string
  links: {
    posts: string
    files: string
  }
}

export type Student = {
  avatarUrl: string
  handle: string
}

export type Track = {
  title: string
  iconUrl: string
  highlightjsLanguage: string
}

export type Exercise = {
  title: string
}

type DiscussionProps = {
  student: Student
  track: Track
  exercise: Exercise
  links: Links
  discussionId: number
  iterations: readonly Iteration[]
}

export const Discussion = ({
  student,
  track,
  exercise,
  links,
  discussionId,
  iterations,
}: DiscussionProps): JSX.Element => {
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
      <article>
        <div className="lhs">
          <IterationHeader
            iteration={currentIteration}
            latest={iterations[iterations.length - 1] === currentIteration}
          />
          <IterationFiles
            endpoint={currentIteration.links.files}
            language={track.highlightjsLanguage}
          />
          {links.markAsNothingToDo ? (
            <MarkAsNothingToDoButton endpoint={links.markAsNothingToDo} />
          ) : null}
        </div>
        <div className="rhs">
          <MentoringPanelList
            links={links}
            discussionId={discussionId}
            iteration={currentIteration}
          />
        </div>
      </article>
    </div>
  )
}
