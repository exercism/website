import React, { createContext, useState } from 'react'
import { TabContext } from '@/components/common/Tab'
import { Tabs } from './Tabs'
import { Panels } from './Panels/Panels'

type TabIndex = 'html' | 'css' | 'javascript'

export const TabsContext = createContext<TabContext>({
  current: 'instructions',
  switchToTab: () => {},
})

export function LHS() {
  const [tab, setTab] = useState<TabIndex>('html')
  return (
    <div className="page-body-lhs">
      <TabsContext.Provider
        value={{
          current: tab,
          switchToTab: (id: string) => {
            setTab(id as TabIndex)
          },
        }}
      >
        <div className="c-iteration-pane">
          <Tabs />
          <Panels />
        </div>
      </TabsContext.Provider>
    </div>
  )
}
