import React from 'react'
import { Tab, GraphicalIcon } from '@/components/common'
import { TabsContext } from '@/components/Editor'

export const InstructionsTab = () => (
  <Tab id="instructions" context={TabsContext}>
    <GraphicalIcon icon="instructions" />
    <span data-text="Instructions">Instructions</span>
  </Tab>
)
