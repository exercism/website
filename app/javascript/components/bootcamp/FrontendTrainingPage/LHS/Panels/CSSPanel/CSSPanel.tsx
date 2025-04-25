import React from 'react'
import { Tab } from '@/components/common'
import { TabsContext } from '../../LHS'
import { CSSEditor } from './CSSEditor'

export function CSSPanel() {
  return (
    <Tab.Panel alwaysAttachToDOM id="css" context={TabsContext}>
      <CSSEditor />
    </Tab.Panel>
  )
}
