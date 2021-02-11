import React, { useState, createContext } from 'react'

import { IterationsList } from './solution/IterationsList'
import { CloseButton } from './solution/CloseButton'
import { SolutionInfo } from './solution/SolutionInfo'
import { IterationFiles } from './solution/IterationFiles'
import { IterationHeader } from './solution/IterationHeader'
import { Guidance } from './solution/Guidance'
import { Scratchpad } from './solution/Scratchpad'
import { StudentInfo } from './solution/StudentInfo'
import { SolutionContext } from './solution/SolutionContext'

import { DiscussionDetails } from './discussion/DiscussionDetails'
import { DiscussionActions } from './discussion/DiscussionActions'
import { AddDiscussionPostPanel } from './discussion/AddDiscussionPostPanel'

import { Tab, TabContext } from '../common/Tab'
import { Icon } from '../common/Icon'
import { GraphicalIcon } from '../common/GraphicalIcon'

export type Links = {
  mentorDashboard: string
  scratchpad: string
}

type RepresenterFeedbackAuthor = {
  avatarUrl: string
  name: string
  reputation: number
  profileUrl: string
}

type AnalyzerFeedbackTeam = {
  name: string
  linkUrl: string
}

export type RepresenterFeedback = {
  html: string
  author: RepresenterFeedbackAuthor
}

export type AnalyzerFeedback = {
  html: string
  team: AnalyzerFeedbackTeam
}

export type AutomatedFeedback = {
  mentor?: RepresenterFeedback
  analyzer?: AnalyzerFeedback
}

export type Iteration = {
  uuid: string
  idx: number
  numComments: number
  unread: boolean
  createdAt: string
  testsStatus: string
  automatedFeedback: AutomatedFeedback
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

export type MentorSolution = {
  snippet: string
  numLoc: string
  numStars: string
  numComments: string
  publishedAt: string
  webUrl: string
  mentor: {
    handle: string
    avatarUrl: string
  }
  language: string
}

export type StudentMentorRelationship = {
  isFavorited: boolean
  isBlocked: boolean
  links: {
    block: string
    favorite: string
  }
}

export type Discussion = {
  isFinished: boolean
  id: string
  links: {
    posts: string
    markAsNothingToDo?: string
    finish: string
  }
}

export type SolutionProps = {
  student: Student
  track: Track
  exercise: Exercise
  links: Links
  discussion: Discussion
  iterations: readonly Iteration[]
  userId: number
  notes: string
  mentorSolution: MentorSolution
  relationship: StudentMentorRelationship
}

export type TabIndex = 'discussion' | 'scratchpad' | 'guidance'

export const TabsContext = createContext<TabContext>({
  current: 'instructions',
  switchToTab: () => {},
})

export const Solution = (props: SolutionProps): JSX.Element => {
  const [solution, setSolution] = useState(props)
  const {
    student,
    track,
    exercise,
    links,
    iterations,
    discussion,
    relationship,
    notes,
    mentorSolution,
  } = solution
  const [currentIteration, setCurrentIteration] = useState(
    iterations[iterations.length - 1]
  )
  const [tab, setTab] = useState<TabIndex>('discussion')

  return (
    <SolutionContext solution={solution} setSolution={setSolution}>
      <div className="c-mentor-discussion">
        <div className="lhs">
          <header className="discussion-header">
            <CloseButton url={links.mentorDashboard} />
            <SolutionInfo student={student} track={track} exercise={exercise} />
            {discussion ? <DiscussionActions {...discussion} /> : null}
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
          <TabsContext.Provider
            value={{
              current: tab,
              switchToTab: (id: string) => setTab(id as TabIndex),
            }}
          >
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
              <StudentInfo student={student} />
              {discussion ? (
                <DiscussionDetails
                  discussion={discussion}
                  iterations={iterations}
                  student={student}
                  relationship={relationship}
                />
              ) : null}
            </Tab.Panel>
            <Tab.Panel id="scratchpad" context={TabsContext}>
              <Scratchpad endpoint={links.scratchpad} />
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
            ) : null}
          </TabsContext.Provider>
        </div>
      </div>
    </SolutionContext>
  )
}
