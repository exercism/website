import React from 'react'
import { Tab } from '../../common/Tab'
import { TabsContext } from '../../Editor'
import { GraphicalIcon } from '../../common/GraphicalIcon'

export const GetHelpTab = (): JSX.Element => (
  <Tab id="get-help" context={TabsContext}>
    <GraphicalIcon icon="help" />
    <span data-text="Get Help">Get help</span>
  </Tab>
)
