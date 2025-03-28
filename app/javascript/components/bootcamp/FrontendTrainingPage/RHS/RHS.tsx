import React, { createContext, useState } from 'react'
import { TabContext } from '@/components/common/Tab'
import { Tabs } from './Tabs'
import { Panels } from './Panels/Panels'
import { useFrontendTrainingPageStore } from '../store/frontendTrainingPageStore'
import {
  Resizer,
  useResizablePanels,
} from '../../JikiscriptExercisePage/hooks/useResize'

type TabIndex = 'instructions' | 'output'

export const TabsContext = createContext<TabContext>({
  current: 'instructions',
  switchToTab: () => {},
})

export function RHS() {
  const [tab, setTab] = useState<TabIndex>('output')
  const {
    panelSizes: { RHSWidth },
  } = useFrontendTrainingPageStore()

  const {
    primarySize: TopHeight,
    secondarySize: BottomHeight,
    handleMouseDown: handleHeightChangeMouseDown,
  } = useResizablePanels({
    initialSize: 800,
    direction: 'vertical',
    localStorageId: 'frontend-training-page-rhs-height',
  })

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
        <div className="c-iteration-pane" style={{ height: TopHeight }}>
          <Tabs />
          <Panels />
        </div>
      </TabsContext.Provider>
      <Resizer
        direction="horizontal"
        handleMouseDown={handleHeightChangeMouseDown}
      />
      <div
        style={{ height: BottomHeight }}
        className="bg-gray-400 grid place-content-center"
      >
        Results here
      </div>
    </div>
  )
}
