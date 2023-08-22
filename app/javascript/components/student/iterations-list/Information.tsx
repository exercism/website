import React, { useState, createContext } from 'react'
import { AnalysisInformation } from './AnalysisInformation'
import { TestsInformation } from './TestsInformation'
import { Iteration } from '../../types'
import { Exercise, Track, Links } from '../IterationsList'
import { Tab, TabContext } from '../../common/Tab'
import { OptionsDropdown } from './OptionsDropdown'
import { GraphicalIcon } from '../../common'

type TabIndex = 'analysis' | 'tests'

export const TabsContext = createContext<TabContext>({
  current: 'analysis',
  switchToTab: () => null,
})

export const Information = ({
  iteration,
  exercise,
  track,
  links,
  onDelete,
}: {
  iteration: Iteration
  exercise: Exercise
  track: Track
  links: Links
  onDelete: (iteration: Iteration) => void
}): JSX.Element | null => {
  const [tab, setTab] = useState<TabIndex>('analysis')

  return (
    <TabsContext.Provider
      value={{
        current: tab,
        switchToTab: (id: string) => setTab(id as TabIndex),
      }}
    >
      <div className="tabs">
        <Tab id="analysis" context={TabsContext} className="--small">
          <GraphicalIcon icon="automation" />
          Analysis
        </Tab>
        <Tab id="tests" context={TabsContext} className="--small">
          <GraphicalIcon icon="tests" />
          Tests
        </Tab>
        <OptionsDropdown iteration={iteration} onDelete={onDelete} />
      </div>
      <div className="panels">
        <Tab.Panel
          id="analysis"
          context={TabsContext}
          className="analysis-panel"
        >
          <AnalysisInformation
            iteration={iteration}
            exercise={exercise}
            track={track}
            links={links}
          />
        </Tab.Panel>
        <Tab.Panel id="tests" context={TabsContext} className="tests-panel">
          <TestsInformation
            request={{
              endpoint: iteration.links.testRun,
              options: { enabled: tab === 'tests' },
            }}
          />
        </Tab.Panel>
      </div>
    </TabsContext.Provider>
  )
}
