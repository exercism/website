import { Tab } from '@/components/common'
import React from 'react'
import { Instructions } from '../../Instructions'
import { TabsContext } from '../RHS'

export function InstructionsPanel() {
  return (
    <Tab.Panel id="instructions" context={TabsContext}>
      <Instructions
        exerciseTitle="Css world!"
        exerciseInstructions="<div>Follow these instructions</div>"
      />
    </Tab.Panel>
  )
}
