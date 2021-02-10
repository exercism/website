import React, { createContext, useEffect, useRef, useState } from 'react'
import { Tab, TabContext } from '../../common/Tab'
import { DiscussionPostList } from './DiscussionPostList'
import { Scratchpad } from './Scratchpad'
import { Guidance } from './Guidance'
import { StudentInfo } from './StudentInfo'
import { GraphicalIcon } from '../../common'
import {
  TabIndex,
  Student,
  Iteration,
  MentorSolution,
  Track,
  Exercise,
  StudentMentorRelationship,
} from '../Discussion'
import { DiscussionPostProps } from './DiscussionPost'
import { FinishedWizard } from './FinishedWizard'

type MentoringPanelListLinks = {
  scratchpad: string
  posts: string
}

const TabsContext = createContext<TabContext>({
  current: 'instructions',
  switchToTab: () => {},
})

export const MentoringPanelList = ({
  isFinished,
  relationship,
  links,
  discussionId,
  tab,
  setTab,
  student,
  iterations,
  onPostsChange,
  onPostHighlight,
  onAfterPostHighlight,
  highlightedPost,
  notes,
  mentorSolution,
  track,
  exercise,
}: {
  isFinished: boolean
  relationship: StudentMentorRelationship
  links: MentoringPanelListLinks
  discussionId: number
  tab: TabIndex
  setTab: (id: TabIndex) => void
  student: Student
  iterations: readonly Iteration[]
  onPostsChange: (posts: DiscussionPostProps[]) => void
  onPostHighlight: (element: HTMLDivElement) => void
  onAfterPostHighlight: () => void
  highlightedPost: DiscussionPostProps | null
  notes: string
  mentorSolution: MentorSolution
  track: Track
  exercise: Exercise
}): JSX.Element => {
  const previouslyNotFinishedRef = useRef(!isFinished)
  const finishedWizardRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!finishedWizardRef.current) {
      return
    }

    finishedWizardRef.current.scrollIntoView()
  }, [relationship])

  return (
    <>
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
          <DiscussionPostList
            endpoint={links.posts}
            iterations={iterations}
            discussionId={discussionId}
            onPostsChange={onPostsChange}
            onPostHighlight={onPostHighlight}
            onAfterPostHighlight={onAfterPostHighlight}
            highlightedPost={highlightedPost}
            student={student}
          />
          {isFinished ? (
            <FinishedWizard
              ref={finishedWizardRef}
              student={student}
              relationship={relationship}
              step={previouslyNotFinishedRef.current ? 'mentorAgain' : 'finish'}
            />
          ) : null}
        </Tab.Panel>
        <Tab.Panel id="scratchpad" context={TabsContext}>
          <Scratchpad endpoint={links.scratchpad} discussionId={discussionId} />
        </Tab.Panel>
        <Tab.Panel id="guidance" context={TabsContext}>
          <Guidance
            notes={notes}
            mentorSolution={mentorSolution}
            track={track}
            exercise={exercise}
          />
        </Tab.Panel>
      </TabsContext.Provider>
    </>
  )
}
