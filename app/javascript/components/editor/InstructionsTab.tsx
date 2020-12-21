import React from 'react'
import { Tab } from '../common/Tab'
import { TabsContext } from '../Editor'
import { GraphicalIcon } from '../common/GraphicalIcon'

export const InstructionsTab = () => (
  <Tab index="instructions" context={TabsContext}>
    <GraphicalIcon icon="editor" />
    <span data-text="Instructions">Instructions</span>
  </Tab>
)
