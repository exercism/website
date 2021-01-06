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
  current: 'instructions',
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
      value={{
        current: tab,
        switchToTab: (id: string) => setTab(id as TabIndex),
      }}
    >
      <div className="tabs" role="tablist">
        <Tab id="discussion" context={TabsContext}>
          <GraphicalIcon icon="comment" />
          Discussion
        </Tab>
        <Tab id="scratchpad" context={TabsContext}>
          <GraphicalIcon icon="scratchpad" />
          Scratchpad
        </Tab>
        <Tab id="guidance" context={TabsContext}>
          <GraphicalIcon icon="guidance" />
          Guidance
        </Tab>
      </div>
      <Tab.Panel id="discussion" context={TabsContext}>
        <DiscussionPostPanel
          endpoint={links.posts}
          discussionId={discussionId}
          iterationIdx={iterationIdx}
        />
      </Tab.Panel>
      <Tab.Panel id="scratchpad" context={TabsContext}>
        <Scratchpad endpoint={links.scratchpad} discussionId={discussionId} />
      </Tab.Panel>
      <Tab.Panel id="guidance" context={TabsContext}>
        <Guidance />
      </Tab.Panel>
    </TabsContext.Provider>
  )
}
