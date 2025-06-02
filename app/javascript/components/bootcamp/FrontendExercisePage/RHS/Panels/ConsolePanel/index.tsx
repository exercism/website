import { Tab } from '@/components/common'
import React from 'react'
import { TabsContext } from '../../RHS'
import { Logger } from './Logger'

export function ConsolePanel() {
  return (
    <Tab.Panel alwaysAttachToDOM id="console" context={TabsContext}>
      <Logger />
    </Tab.Panel>
  )
}
