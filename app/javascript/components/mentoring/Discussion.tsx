import React, { useState, createContext, useCallback, useRef } from 'react'
import { MentoringPanelList } from './discussion/MentoringPanelList'
import { IterationsList } from './discussion/IterationsList'
import { CloseButton } from './discussion/CloseButton'
import { SolutionInfo } from './discussion/SolutionInfo'
import { IterationFiles } from './discussion/IterationFiles'
import { IterationHeader } from './discussion/IterationHeader'
import { AddDiscussionPost } from './discussion/AddDiscussionPost'
import { MarkAsNothingToDoButton } from './discussion/MarkAsNothingToDoButton'
import { DiscussionPostProps } from './discussion/DiscussionPost'

import { Icon } from '../common/Icon'
import { GraphicalIcon } from '../common/GraphicalIcon'

export type Links = {
  mentorDashboard: string
  scratchpad: string
  close: string
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
  const [hasNewMessages, setHasNewMessages] = useState(false)
  const [
    highlightedPost,
    setHighlightedPost,
  ] = useState<DiscussionPostProps | null>(null)
  const highlightedPostRef = useRef<HTMLDivElement | null>(null)
  const hasLoadedRef = useRef(false)
  const handlePostsChange = useCallback(
    (posts) => {
      if (!hasLoadedRef.current) {
        hasLoadedRef.current = true
        return
      }

      const lastPost = posts[posts.length - 1]

      setHighlightedPost(lastPost)

      if (lastPost.authorId !== userId) {
        setHasNewMessages(true)
      }
    },
    [userId]
  )
  const handlePostHighlight = useCallback(
    (post) => {
      highlightedPostRef.current = post

      if (!highlightedPost) {
        return
      }

      if (highlightedPost.authorId === userId) {
        post.scrollIntoView()
      }
    },
    [highlightedPost, userId]
  )
  const postsKey = `posts-${discussionId}`

  return (
    <CacheContext.Provider value={{ posts: postsKey }}>
      <div className="c-mentor-discussion">
        <div className="lhs">
          <header className="discussion-header">
            <CloseButton url={links.mentorDashboard} />
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
            <button className="settings-button btn-keyboard-shortcut">
              <Icon icon="settings" alt="Mentor settings" />
            </button>
          </footer>
        </div>
        <div className="rhs">
          <MentoringPanelList
            tab={tab}
            setTab={setTab}
            links={links}
            student={student}
            discussionId={discussionId}
            iterations={iterations}
            highlightedPost={highlightedPost}
            onPostsChange={handlePostsChange}
            onPostHighlight={handlePostHighlight}
            onAfterPostHighlight={() => {
              setHasNewMessages(false)
            }}
          />

          <section className="comment-section">
            {hasNewMessages ? (
              <button
                className="new-messages-button"
                type="button"
                onClick={() => {
                  setTab('discussion')
                  highlightedPostRef.current?.scrollIntoView()
                }}
              >
                <GraphicalIcon icon="comment" />
                <span>New Message</span>
              </button>
            ) : null}
            <AddDiscussionPost
              endpoint={links.posts}
              onSuccess={() => {
                setTab('discussion')
              }}
              contextId={`${discussionId}_new_post`}
            />
          </section>
        </div>
      </div>
    </CacheContext.Provider>
  )
}
