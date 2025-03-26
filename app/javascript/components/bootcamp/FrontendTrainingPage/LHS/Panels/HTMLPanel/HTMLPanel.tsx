import React from 'react'
import { Tab } from '@/components/common'
import { TabsContext } from '@/components/Editor'
import { HTMLEditor } from './HTMLEditor'

export function HTMLPanel() {
  return (
    <Tab.Panel id="html" context={TabsContext}>
      <HTMLEditor />
    </Tab.Panel>
  )
}
