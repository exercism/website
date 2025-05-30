import React, { useState, createContext } from 'react'
import { AnalysisInformation } from './AnalysisInformation'
import { TestsInformation } from './TestsInformation'
import { Iteration } from '../../types'
import { Exercise, Track, Links } from '../IterationsList'
import { Tab, TabContext } from '../../common/Tab'
import { OptionsDropdown } from './OptionsDropdown'
import { GraphicalIcon } from '../../common'
import { GithubSyncerWidget } from '@/components/github-syncer-widget/GithubSyncerWidget'
import { GithubSyncerSettings } from '@/components/settings/github-syncer/GitHubSyncerForm'
import { Toaster } from 'react-hot-toast'

type TabIndex = 'analysis' | 'tests' | 'backup'

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
  syncer,
}: {
  iteration: Iteration
  exercise: Exercise
  track: Track
  links: Links
  onDelete: (iteration: Iteration) => void
  syncer: GithubSyncerSettings | null
}): JSX.Element | null => {
  const [tab, setTab] = useState<TabIndex>('analysis')

  return (
    <TabsContext.Provider
      value={{
        current: tab,
        switchToTab: (id: string) => setTab(id as TabIndex),
      }}
    >
      <div className="tabs overflow-auto">
        <Tab id="analysis" context={TabsContext} className="--small">
          <GraphicalIcon icon="automation" />
          Analysis
        </Tab>
        <Tab id="tests" context={TabsContext} className="--small">
          <GraphicalIcon icon="tests" />
          Tests
        </Tab>
        <Tab id="github-backup" context={TabsContext} className="--small">
          <GraphicalIcon icon="external-site-github" />
          Backup
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
        <Tab.Panel id="github-backup" context={TabsContext}>
          <GithubSyncerWidget
            sync={{
              endpoint: links.syncIteration,
              body: JSON.stringify({
                iteration_idx: iteration.idx,
                exercise_slug: exercise.slug,
                track_slug: track.slug,
              }),
            }}
            syncer={syncer}
            links={links}
          />
        </Tab.Panel>
      </div>
    </TabsContext.Provider>
  )
}
