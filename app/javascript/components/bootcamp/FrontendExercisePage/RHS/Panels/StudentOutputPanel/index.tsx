import { Tab } from '@/components/common'
import React from 'react'
import { ActualOutput } from './ActualOutput'
import { TabsContext } from '../../RHS'

export function StudentOutputPanel() {
  return (
    <Tab.Panel
      className="h-100 p-16"
      alwaysAttachToDOM
      id="output"
      context={TabsContext}
    >
      <ActualOutput />
    </Tab.Panel>
  )
}
