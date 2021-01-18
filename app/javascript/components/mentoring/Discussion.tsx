import React, { useState, createContext } from 'react'
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
  name: string
  bio: string
  languagesSpoken: string[]
  handle: string
  reputation: number
  isFavorite: boolean
  numPreviousSessions: number
  links: {
    favorite: string
  }
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
  userId: number
}

export type TabIndex = 'discussion' | 'scratchpad' | 'guidance'

export const CacheContext = createContext({ posts: '' })

export const Discussion = ({
  student,
  track,
  exercise,
  links,
  discussionId,
  iterations,
  userId,
}: DiscussionProps): JSX.Element => {
  const [currentIteration, setCurrentIteration] = useState(
    iterations[iterations.length - 1]
  )
  const [tab, setTab] = useState<TabIndex>('discussion')
  const postsKey = `posts-${discussionId}`

  return (
    <CacheContext.Provider value={{ posts: postsKey }}>
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
            student={student}
            userId={userId}
            discussionId={discussionId}
            iterations={iterations}
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
    </CacheContext.Provider>
  )
}
