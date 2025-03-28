import React, { createContext, useState } from 'react'
import { TabContext } from '@/components/common/Tab'
import { Tabs } from './Tabs'
import { Panels } from './Panels/Panels'
import { useCSSTrainingPageStore } from '../store/cssExercisePageStore'

type TabIndex = 'instructions' | 'output'

export const TabsContext = createContext<TabContext>({
  current: 'instructions',
  switchToTab: () => {},
})

export function RHS() {
  const [tab, setTab] = useState<TabIndex>('output')
  const {
    panelSizes: { RHSWidth },
  } = useCSSTrainingPageStore()
  return (
    <div className="page-body-rhs" style={{ width: RHSWidth }}>
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
