import React from 'react'
import { Tab } from '../common/Tab'
import { TabsContext } from '../Editor'
import { GraphicalIcon } from '../common/GraphicalIcon'

export const ResultsTab = (): JSX.Element => (
  <Tab id="results" context={TabsContext}>
    <GraphicalIcon icon="test-results" />
    <span data-text="Results">Results</span>
  </Tab>
)
