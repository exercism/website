import React from 'react'
import { Tab } from './Tab'
import { TabIndex } from '../Editor'
import { GraphicalIcon } from '../common/GraphicalIcon'

export const InstructionsTab = () => (
  <Tab index={TabIndex.INSTRUCTIONS}>
    <GraphicalIcon icon="editor" />
    <span data-text="Instructions">Instructions</span>
  </Tab>
)
