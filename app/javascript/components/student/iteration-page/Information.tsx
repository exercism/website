import React, { useState, createContext } from 'react'
import { AnalysisInformation } from './AnalysisInformation'
import { TestsInformation } from './TestsInformation'
import { Iteration } from '../../types'
import { Exercise, Track, Links } from '../IterationPage'
import { Tab, TabContext } from '../../common/Tab'

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
      <Tab id="analysis" context={TabsContext}>
        Analysis
      </Tab>
      <Tab id="tests" context={TabsContext}>
        Tests
      </Tab>
      <Tab.Panel id="analysis" context={TabsContext}>
        <AnalysisInformation
          iteration={iteration}
          exercise={exercise}
          track={track}
          links={links}
        />
      </Tab.Panel>
      <Tab.Panel id="tests" context={TabsContext}>
        <TestsInformation
          request={{
            endpoint: iteration.links.testRun,
            options: { enabled: tab === 'tests' },
          }}
        />
      </Tab.Panel>
    </TabsContext.Provider>
  )
}
