import React, { createContext } from 'react'
import { Tab, TabContext } from '../../common/Tab'
import { DiscussionPostList } from './DiscussionPostList'
import { Scratchpad } from './Scratchpad'
import { Guidance } from './Guidance'
import { StudentInfo } from './StudentInfo'
import { GraphicalIcon } from '../../common'
import { TabIndex, Student } from '../Discussion'

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
}: {
  links: MentoringPanelListLinks
  discussionId: number
  tab: TabIndex
  setTab: (id: TabIndex) => void
  student: Student
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
            discussionId={discussionId}
          />
        </Tab.Panel>
        <Tab.Panel id="scratchpad" context={TabsContext}>
          <Scratchpad endpoint={links.scratchpad} discussionId={discussionId} />
        </Tab.Panel>
        <Tab.Panel id="guidance" context={TabsContext}>
          <Guidance />
        </Tab.Panel>
      </TabsContext.Provider>
    </>
  )
}
