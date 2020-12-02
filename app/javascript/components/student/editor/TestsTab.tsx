import React from 'react'
import { Tab } from './Tab'
import { TabIndex } from '../Editor'
import { GraphicalIcon } from '../../common/GraphicalIcon'

export const TestsTab = () => (
  <Tab index={TabIndex.TESTS}>
    <GraphicalIcon icon="tests" />
    <span data-text="Tests">Tests</span>
  </Tab>
)
