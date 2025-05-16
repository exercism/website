import React, { createContext, useState } from 'react'
import { TabContext } from '@/components/common/Tab'
import { Tabs } from './Tabs'
import { Panels } from './Panels/Panels'
import { useFrontendExercisePageStore } from '../store/frontendExercisePageStore'

type TabIndex = 'instructions' | 'output'

export const TabsContext = createContext<TabContext>({
  current: 'instructions',
  switchToTab: () => {},
})

export function RHS() {
  const [tab, setTab] = useState<TabIndex>('output')
  const {
    panelSizes: { RHSWidth },
  } = useFrontendExercisePageStore()

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
        <div className="c-iteration-pane h-100">
          <Tabs />
          <Panels />
        </div>
      </TabsContext.Provider>
    </div>
  )
}
