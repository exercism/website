import { Tab } from '@/components/common'
import React from 'react'
import { ActualOutput } from '../../ActualOutput'
import { ExpectedOutput } from '../../ExpectedOutput'
import { TabsContext } from '../RHS'

export function OutputPanel() {
  return (
    <Tab.Panel alwaysAttachToDOM id="output" context={TabsContext}>
      <div className="flex flex-col gap-12">
        <ActualOutput />
        <ExpectedOutput />
      </div>
    </Tab.Panel>
  )
}
