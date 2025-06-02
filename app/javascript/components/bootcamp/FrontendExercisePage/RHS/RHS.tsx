import React, { createContext } from 'react'
import { TabContext } from '@/components/common/Tab'
import { Tabs } from './Tabs'
import { Panels } from './Panels/Panels'
import {
  TabIndex,
  useFrontendExercisePageStore,
} from '../store/frontendExercisePageStore'

export const TabsContext = createContext<TabContext>({
  current: '',
  switchToTab: () => {},
})

export function RHS() {
  const {
    RHSActiveTab: tab,
    setRHSActiveTab: setTab,
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
