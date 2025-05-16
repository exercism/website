import { Tab } from '@/components/common'
import React from 'react'
import { TabsContext } from '../../RHS'
import { ExpectedOutput } from './ExpectedOutput'

export function ExpectedOutputPanel() {
  return (
    <Tab.Panel
      className="h-100 p-16"
      alwaysAttachToDOM
      id="expected"
      context={TabsContext}
    >
      <ExpectedOutput />
    </Tab.Panel>
  )
}
