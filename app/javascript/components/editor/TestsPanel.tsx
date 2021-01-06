import React from 'react'
import { Tab } from '../common/Tab'
import { TabsContext } from '../Editor'

export const TestsPanel = () => (
  <Tab.Panel id="tests" context={TabsContext}>
    <section className="tests"></section>
  </Tab.Panel>
)
