import React, { useState, createContext, useCallback } from 'react'

import { CommunitySolution, Student } from '../types'
import { CloseButton } from './session/CloseButton'
import { SessionInfo } from './session/SessionInfo'
import { Guidance } from './session/Guidance'
import { Scratchpad } from './session/Scratchpad'
import { StudentInfo } from './session/StudentInfo'
import { IterationView } from './session/IterationView'

import { DiscussionDetails } from './discussion/DiscussionDetails'
import { DiscussionActions } from './discussion/DiscussionActions'
import { AddDiscussionPostPanel } from './discussion/AddDiscussionPostPanel'
import { useDiscussionIterations } from './discussion/use-discussion-iterations'

import { RequestDetails } from './request/RequestDetails'
import { MentoringRequestPanel } from './request/MentoringRequestPanel'

import { Tab, TabContext } from '../common/Tab'
import { GraphicalIcon } from '../common/GraphicalIcon'
import { PostsWrapper } from './discussion/PostsContext'

import {
  MentorSessionRequest as Request,
  Iteration,
  MentorDiscussion as Discussion,
  MentorSessionTrack as Track,
  MentorSessionExercise as Exercise,
} from '../types'

import { useIterationScrolling } from './session/useIterationScrolling'
import { SplitPane } from '../common'
import { FavoritableStudent } from './session/FavoriteButton'

export type Settings = {
  scroll: boolean
  click: boolean
}

export type Links = {
  mentorDashboard: string
  previousSessions: string
}

export type Scratchpad = {
  isIntroducerHidden: boolean
  links: {
    markdown: string
    hideIntroducer: string
    self: string
  }
}

export type SessionProps = {
  student: Student
  track: Track
  exercise: Exercise
  links: Links
  discussion: Discussion
  iterations: readonly Iteration[]
  userHandle: string
  notes: string
  outOfDate: boolean
  mentorSolution: CommunitySolution
  request: Request
  scratchpad: Scratchpad
}

export type TabIndex = 'discussion' | 'scratchpad' | 'guidance'

export const TabsContext = createContext<TabContext>({
  current: 'instructions',
  switchToTab: () => {},
})

export const Session = (props: SessionProps): JSX.Element => {
  const [session, setSession] = useState(props)
  const {
    student,
    track,
    exercise,
    links,
    iterations: initialIterations,
    discussion,
    notes,
    mentorSolution,
    outOfDate,
    request,
    scratchpad,
    userHandle,
  } = session
  const [tab, setTab] = useState<TabIndex>('discussion')

  const setStudent = useCallback(
    (student: Student) => {
      setSession({ ...session, student: student })
    },
    [session]
  )

  const { iterations, status } = useDiscussionIterations({
    discussion: discussion,
    iterations: initialIterations,
  })

  const [settings, setSettings] = useState({ scroll: false, click: false })
  const {
    currentIteration,
    handleIterationClick,
    handleIterationScroll,
  } = useIterationScrolling({
    iterations: iterations,
    isScrollOn: settings.scroll,
    isClickOn: settings.click,
  })

  return (
    <div className="c-mentor-discussion">
      <SplitPane
        id="mentoring-session"
        defaultLeftWidth="90%"
        leftMinWidth={550}
        rightMinWidth={625}
        left={
          <>
            <header className="discussion-header">
              <CloseButton url={links.mentorDashboard} />
              <SessionInfo
                student={student}
                track={track}
                exercise={exercise}
              />
              {discussion ? (
                <DiscussionActions
                  {...discussion}
                  session={session}
                  setSession={setSession}
                />
              ) : null}
            </header>
            <IterationView
              iterations={iterations}
              currentIteration={currentIteration}
              onClick={handleIterationClick}
              isOutOfDate={outOfDate}
              language={track.highlightjsLanguage}
              indentSize={track.indentSize}
              settings={settings}
              setSettings={setSettings}
            />
          </>
        }
        right={
          <PostsWrapper discussion={session.discussion}>
            <TabsContext.Provider
              value={{
                current: tab,
                switchToTab: (id: string) => setTab(id as TabIndex),
              }}
            >
              <>
                <div className="tabs" role="tablist">
                  <Tab id="discussion" context={TabsContext}>
                    <GraphicalIcon icon="comment" />
                    <Tab.Title text="Discussion" />
                  </Tab>
                  <Tab id="scratchpad" context={TabsContext}>
                    <GraphicalIcon icon="scratchpad" />
                    <Tab.Title text="Scratchpad" />
                  </Tab>
                  <Tab id="guidance" context={TabsContext}>
                    <GraphicalIcon icon="guidance" />
                    <Tab.Title text="Guidance" />
                  </Tab>
                </div>
                <Tab.Panel id="discussion" context={TabsContext}>
                  <StudentInfo
                    student={student}
                    setStudent={setStudent}
                    links={links}
                  />
                  {discussion ? (
                    <DiscussionDetails
                      status={status}
                      discussion={discussion}
                      iterations={iterations}
                      student={student as FavoritableStudent}
                      userHandle={userHandle}
                      onIterationScroll={handleIterationScroll}
                    />
                  ) : (
                    <RequestDetails
                      iteration={iterations[iterations.length - 1]}
                      request={request}
                    />
                  )}
                </Tab.Panel>
                <Tab.Panel id="scratchpad" context={TabsContext}>
                  <Scratchpad
                    scratchpad={scratchpad}
                    track={track}
                    exercise={exercise}
                  />
                </Tab.Panel>
                <Tab.Panel id="guidance" context={TabsContext}>
                  <Guidance
                    notes={notes}
                    mentorSolution={mentorSolution}
                    track={track}
                    exercise={exercise}
                  />
                </Tab.Panel>
                {discussion ? (
                  <AddDiscussionPostPanel discussion={discussion} />
                ) : (
                  <MentoringRequestPanel
                    iterations={iterations}
                    request={request}
                    session={session}
                    setSession={setSession}
                  />
                )}
              </>
            </TabsContext.Provider>
          </PostsWrapper>
        }
      />
    </div>
  )
}
