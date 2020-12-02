import React from 'react'
import { Tab } from './Tab'
import { TabIndex } from '../Editor'
import { GraphicalIcon } from '../../common/GraphicalIcon'

export const ResultsTab = () => (
  <Tab index={TabIndex.RESULTS}>
    <GraphicalIcon icon="test-results" />
    <span data-text="Results">Results</span>
  </Tab>
)
