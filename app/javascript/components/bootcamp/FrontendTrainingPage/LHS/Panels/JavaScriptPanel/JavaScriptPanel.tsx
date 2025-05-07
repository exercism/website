import React from 'react'
import { Tab } from '@/components/common'
import { TabsContext } from '../../LHS'
import { JavaScriptEditor } from './JavaScriptEditor'

export function JavaScriptPanel() {
  return (
    <Tab.Panel alwaysAttachToDOM id="javascript" context={TabsContext}>
      <JavaScriptEditor />
    </Tab.Panel>
  )
}
