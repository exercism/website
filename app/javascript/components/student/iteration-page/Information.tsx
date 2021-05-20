import React, { useState, createContext } from 'react'
import { AnalysisInformation } from './AnalysisInformation'
import { TestsInformation } from './TestsInformation'
import { Iteration } from '../../types'
import { Exercise, Track, Links } from '../IterationPage'
import { Tab, TabContext } from '../../common/Tab'
import { GraphicalIcon } from '../../common'

type TabIndex = 'analysis' | 'tests'

export const TabsContext = createContext<TabContext>({
  current: 'analysis',
  switchToTab: () => {},
})

export const Information = ({
  iteration,
  exercise,
  track,
  links,
}: {
  iteration: Iteration
  exercise: Exercise
  track: Track
  links: Links
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
