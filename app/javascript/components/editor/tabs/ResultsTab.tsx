import React from 'react'
import { Tab, GraphicalIcon } from '@/components/common'
import { TabsContext } from '@/components/Editor'

export const ResultsTab = (): JSX.Element => (
  <Tab id="results" context={TabsContext}>
    <GraphicalIcon icon="test-results" />
    <span data-text="Results">Results</span>
  </Tab>
)
