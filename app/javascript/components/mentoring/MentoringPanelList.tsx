import React, { useState, createContext } from 'react'
import { Tab, TabContext } from '../common/Tab'

type TabIndex = 'discussion' | 'scratchpad'

const TabsContext = createContext<TabContext>({
  tab: 'instructions',
  switchToTab: () => {},
})

export const MentoringPanelList = (): JSX.Element => {
  const [tab, setTab] = useState<TabIndex>('discussion')

  return (
    <TabsContext.Provider
      value={{ tab, switchToTab: (index: string) => setTab(index as TabIndex) }}
    >
      <div>
        <div role="tablist">
          <Tab index="discussion" context={TabsContext}>
            Discussion
          </Tab>
          <Tab index="scratchpad" context={TabsContext}>
            Scratchpad
          </Tab>
        </div>
        <Tab.Panel index="discussion" context={TabsContext}>
          <p>Discussion</p>
        </Tab.Panel>
        <Tab.Panel index="scratchpad" context={TabsContext}>
          <p>Scratchpad</p>
        </Tab.Panel>
      </div>
    </TabsContext.Provider>
  )
}
