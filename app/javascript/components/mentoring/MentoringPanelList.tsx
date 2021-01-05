import React, { useState, createContext } from 'react'
import { Tab, TabContext } from '../common/Tab'
import { DiscussionPostPanel } from './DiscussionPostPanel'
import { Scratchpad } from './Scratchpad'
import { Guidance } from './Guidance'
import { GraphicalIcon } from '../common'

type TabIndex = 'discussion' | 'scratchpad'

type MentoringPanelListLinks = {
  posts: string
  scratchpad: string
}

const TabsContext = createContext<TabContext>({
  tab: 'instructions',
  switchToTab: () => {},
})

export const MentoringPanelList = ({
  links,
  discussionId,
  iterationIdx,
}: {
  links: MentoringPanelListLinks
  discussionId: number
  iterationIdx: number
}): JSX.Element => {
  const [tab, setTab] = useState<TabIndex>('discussion')

  return (
    <TabsContext.Provider
      value={{ tab, switchToTab: (index: string) => setTab(index as TabIndex) }}
    >
      <div className="tabs" role="tablist">
        <Tab index="discussion" context={TabsContext}>
          <GraphicalIcon icon="comment" />
          Discussion
        </Tab>
        <Tab index="scratchpad" context={TabsContext}>
          <GraphicalIcon icon="scratchpad" />
          Scratchpad
        </Tab>
        <Tab index="guidance" context={TabsContext}>
          <GraphicalIcon icon="guidance" />
          Guidance
        </Tab>
      </div>
      <Tab.Panel index="discussion" context={TabsContext}>
        <DiscussionPostPanel
          endpoint={links.posts}
          discussionId={discussionId}
          iterationIdx={iterationIdx}
        />
      </Tab.Panel>
      <Tab.Panel index="scratchpad" context={TabsContext}>
        <Scratchpad endpoint={links.scratchpad} discussionId={discussionId} />
      </Tab.Panel>
      <Tab.Panel index="guidance" context={TabsContext}>
        <Guidance />
      </Tab.Panel>
    </TabsContext.Provider>
  )
}
