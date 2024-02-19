import React, {
  useState,
  createContext,
  useCallback,
  useEffect,
  useContext,
} from 'react'

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
  TestFile,
} from '../types'

import { useIterationScrolling } from './session/useIterationScrolling'
import { SplitPane } from '../common/SplitPane'
import { FavoritableStudent } from './session/FavoriteButton'
import {
  MentorRequestChannel,
  ChannelResponse as MentorRequestChannelResponse,
} from '@/channels/mentorRequestChannel'
import { CancelledRequestModal } from './session/CancelledRequestModal'
import { ScreenSizeContext } from './session/ScreenSizeContext'
import { MobileCodePanel } from './session/mobile-code-panel/MobileCodePanel'
import { usePanelFallback } from './session/mobile-code-panel/usePanelFallback'

export type Links = {
  mentorDashboard: string
  mentorQueue: string
  exercise: string
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
  testFiles: readonly TestFile[]
  userHandle: string
  guidance: SessionGuidance
  outOfDate: boolean
  mentorSolution: CommunitySolution
  exemplarFiles: readonly MentoringSessionExemplarFile[]
  request: Request
  scratchpad: Scratchpad
  downloadCommand: string
  studentSolutionUuid: string
}

export type SessionGuidance = Pick<
  GuidanceTypes,
  'exercise' | 'track' | 'links'
>

export type TabIndex = 'discussion' | 'scratchpad' | 'guidance' | 'code'

export const TabsContext = createContext<TabContext>({
  current: 'instructions',
  switchToTab: () => null,
})

export default function Session(props: SessionProps): JSX.Element {
  const [session, setSession] = useState(props)
  const {
    student,
    track,
    exercise,
    links,
    iterations: initialIterations,
    instructions,
    testFiles,
    discussion,
    guidance,
    mentorSolution,
    exemplarFiles,
    outOfDate,
    request,
    scratchpad,
    userHandle,
    downloadCommand,
    studentSolutionUuid,
  } = session
  const [tab, setTab] = useState<TabIndex>('discussion')

  const setStudent = useCallback(
    (student: Student) => {
      setSession({ ...session, student: student })
    },
    [session]
  )

  const { iterations, setIterations, status } = useDiscussionIterations({
    discussion: discussion,
    iterations: initialIterations,
    studentSolutionUuid,
  })

  const [isLinked, setIsLinked] = useState(false)
  const [cancelledRequestModalOpen, setCancelledRequestModalOpen] =
    useState(false)
  const { currentIteration, handleIterationClick, handleIterationScroll } =
    useIterationScrolling({
      iterations: iterations,
      on: isLinked,
      setIterations,
    })

  useEffect(() => {
    const mentorRequestChannel = new MentorRequestChannel(
      request,
      (response: MentorRequestChannelResponse) => {
        if (response.mentorRequest.status === 'cancelled') {
          setCancelledRequestModalOpen(true)
        }
      }
    )

    return () => {
      mentorRequestChannel.disconnect()
    }
    // Only run this hook on mount, we don't want to re-establish channel connection when the request updates,
    // because the only relevant information for this hook is the uuid of the request which should never change.
  }, [])

  const { isBelowLgWidth = false } = useContext(ScreenSizeContext) || {}

  usePanelFallback({ tab, setTab, isBelowLgWidth })

  return (
    <div className="c-mentor-discussion">
      <SplitPane
        id="mentoring-session"
        defaultLeftWidth="90%"
        leftMinWidth={550}
        rightMinWidth={isBelowLgWidth ? 0 : 625}
        left={
          <>
            <header className="discussion-header">
              <CloseButton url={links.mentorDashboard} />
              <SessionInfo
                student={student}
                track={track}
                exercise={exercise}
                links={links}
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
              testFiles={testFiles}
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
                  {isBelowLgWidth && (
                    <Tab id="code" context={TabsContext}>
                      <GraphicalIcon icon="comment" />
                      <Tab.Title text="Code" />
                    </Tab>
                  )}
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
                {isBelowLgWidth && (
                  <MobileCodePanel
                    currentIteration={currentIteration}
                    discussion={discussion}
                    downloadCommand={downloadCommand}
                    exercise={exercise}
                    instructions={instructions}
                    isLinked={isLinked}
                    setIsLinked={setIsLinked}
                    iterations={iterations}
                    links={links}
                    onClick={handleIterationClick}
                    outOfDate={outOfDate}
                    session={session}
                    setSession={setSession}
                    student={student}
                    testFiles={testFiles}
                    track={track}
                  />
                )}
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
                    guidance={guidance}
                    mentorSolution={mentorSolution}
                    exemplarFiles={exemplarFiles}
                    language={track.highlightjsLanguage}
                    links={guidance.links}
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
      <CancelledRequestModal
        open={cancelledRequestModalOpen}
        onClose={() => setCancelledRequestModalOpen(false)}
        links={links}
        isLocked={request.isLocked}
      />
    </div>
  )
}
