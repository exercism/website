import React, { useState } from 'react'
import { MentoringPanelList } from './discussion/MentoringPanelList'
import { IterationsList } from './discussion/IterationsList'
import { BackButton } from './discussion/BackButton'
import { SolutionInfo } from './discussion/SolutionInfo'
import { IterationFiles } from './discussion/IterationFiles'
import { IterationHeader } from './discussion/IterationHeader'
import { AddDiscussionPost } from './discussion/AddDiscussionPost'
import { MarkAsNothingToDoButton } from './discussion/MarkAsNothingToDoButton'

export type Links = {
  mentorDashboard: string
  scratchpad: string
  exercise: string
  posts: string
  markAsNothingToDo?: string
}

export type Iteration = {
  uuid: string
  idx: number
  numComments: number
  unread: boolean
  createdAt: string
  testsStatus: string
  links: {
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

export type TabIndex = 'discussion' | 'scratchpad' | 'guidance'

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
  const [tab, setTab] = useState<TabIndex>('discussion')

  return (
    <div className="c-mentor-discussion">
      <div className="lhs">
        <header className="discussion-header">
          <BackButton url={links.mentorDashboard} />
          <SolutionInfo student={student} track={track} exercise={exercise} />
          {links.markAsNothingToDo ? (
            <MarkAsNothingToDoButton endpoint={links.markAsNothingToDo} />
          ) : null}
        </header>
        <IterationHeader
          iteration={currentIteration}
          latest={iterations[iterations.length - 1] === currentIteration}
        />
        <IterationFiles
          endpoint={currentIteration.links.files}
          language={track.highlightjsLanguage}
        />
        <footer className="discussion-footer">
          <IterationsList
            iterations={iterations}
            onClick={setCurrentIteration}
            current={currentIteration}
          />
        </footer>
      </div>
      <div className="rhs">
        <MentoringPanelList
          tab={tab}
          setTab={setTab}
          links={links}
          discussionId={discussionId}
        />
        <AddDiscussionPost
          endpoint={links.posts}
          onSuccess={() => {
            setTab('discussion')
          }}
          contextId={`${discussionId}_new_post`}
        />
      </div>
    </div>
  )
}
