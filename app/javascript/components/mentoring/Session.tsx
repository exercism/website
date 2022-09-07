import React, { useState, createContext, useCallback } from 'react'

import { CommunitySolution, Guidance as GuidanceTypes, Student } from '../types'
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
  MentoringSessionExemplarFile,
} from '../types'

import { useIterationScrolling } from './session/useIterationScrolling'
import { SplitPane } from '../common'
import { FavoritableStudent } from './session/FavoriteButton'

export type Links = {
  mentorDashboard: string
  improveNotes: string
  mentoringDocs: string
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
  instructions: string
  tests: string
  userHandle: string
  guidance: Pick<GuidanceTypes, 'exercise'>
  outOfDate: boolean
  mentorSolution: CommunitySolution
  exemplarFiles: readonly MentoringSessionExemplarFile[]
  request: Request
  scratchpad: Scratchpad
  downloadCommand: string
}

export type TabIndex = 'discussion' | 'scratchpad' | 'guidance'

export const TabsContext = createContext<TabContext>({
  current: 'instructions',
  switchToTab: () => null,
})

export const Session = (props: SessionProps): JSX.Element => {
  const [session, setSession] = useState(props)
  const {
    student,
    track,
    exercise,
    links,
    iterations: initialIterations,
    instructions,
    tests,
    discussion,
    guidance,
    mentorSolution,
    exemplarFiles,
    outOfDate,
    request,
    scratchpad,
    userHandle,
    downloadCommand,
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

  const [isLinked, setIsLinked] = useState(false)
  const { currentIteration, handleIterationClick, handleIterationScroll } =
    useIterationScrolling({ iterations: iterations, on: isLinked })

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
              instructions={instructions}
              tests={tests}
              currentIteration={currentIteration}
              onClick={handleIterationClick}
              isOutOfDate={outOfDate}
              language={track.highlightjsLanguage}
              indentSize={track.indentSize}
              isLinked={isLinked}
              setIsLinked={setIsLinked}
              discussion={discussion}
              downloadCommand={downloadCommand}
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
                  <StudentInfo student={student} setStudent={setStudent} />
                  {discussion ? (
                    <DiscussionDetails
                      status={status}
                      discussion={discussion}
                      iterations={iterations}
                      student={student as FavoritableStudent}
                      setStudent={setStudent}
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
                    notes={guidance.exercise}
                    mentorSolution={mentorSolution}
                    exemplarFiles={exemplarFiles}
                    language={track.highlightjsLanguage}
                    links={links}
                  />
                </Tab.Panel>
                {discussion ? (
                  <AddDiscussionPostPanel
                    discussion={discussion}
                    links={links}
                  />
                ) : (
                  <MentoringRequestPanel
                    iterations={iterations}
                    request={request}
                    session={session}
                    setSession={setSession}
                    links={links}
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
