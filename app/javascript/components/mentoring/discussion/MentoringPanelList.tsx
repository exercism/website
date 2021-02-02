import React, { createContext } from 'react'
import { Tab, TabContext } from '../../common/Tab'
import { DiscussionPostList } from './DiscussionPostList'
import { Scratchpad } from './Scratchpad'
import { Guidance } from './Guidance'
import { StudentInfo } from './StudentInfo'
import { GraphicalIcon } from '../../common'
import { TabIndex, Student, Iteration } from '../Discussion'
import { DiscussionPostProps } from './DiscussionPost'

type MentoringPanelListLinks = {
  scratchpad: string
  posts: string
}

const TabsContext = createContext<TabContext>({
  current: 'instructions',
  switchToTab: () => {},
})

export const MentoringPanelList = ({
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
}: {
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
}): JSX.Element => {
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
        </Tab.Panel>
        <Tab.Panel id="scratchpad" context={TabsContext}>
          <Scratchpad endpoint={links.scratchpad} discussionId={discussionId} />
        </Tab.Panel>
        <Tab.Panel id="guidance" context={TabsContext}>
          <Guidance notes={notes} />
        </Tab.Panel>
      </TabsContext.Provider>
    </>
  )
}
