import React from 'react'
import { Tab } from '@/components/common'
import { TabsContext } from '../../LHS'
import { HTMLEditor } from './HTMLEditor'

export function HTMLPanel() {
  return (
    <Tab.Panel alwaysAttachToDOM id="html" context={TabsContext}>
      <HTMLEditor />
    </Tab.Panel>
  )
}
