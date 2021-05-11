import React from 'react'
import { Tab } from '../common/Tab'
import { TabsContext } from '../Editor'

export const TestsPanel = ({ tests }: { tests: string }) => (
  <Tab.Panel id="tests" context={TabsContext}>
    <section className="tests" dangerouslySetInnerHTML={{ __html: tests }} />
  </Tab.Panel>
)
