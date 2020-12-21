import React from 'react'
import { Tab } from '../common/Tab'
import { TabsContext } from '../Editor'
import { GraphicalIcon } from '../common/GraphicalIcon'

export const TestsTab = () => (
  <Tab index="tests" context={TabsContext}>
    <GraphicalIcon icon="tests" />
    <span data-text="Tests">Tests</span>
  </Tab>
)
