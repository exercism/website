import React, { useState } from 'react'
import { Tab, GraphicalIcon } from '../../../common'
import { CompleteRepresentationData } from '../../../types'
import { TabsContext } from '../../Session'
// import { Guidance } from '../../session/Guidance'
import { Scratchpad } from '../../session/Scratchpad'
import AutomationRules from './AutomationRules'

type RepresentationTabIndex = 'information' | 'scratchpad' | 'guidance'

export function UtilityTabs({
  data,
}: {
  data: CompleteRepresentationData
}): JSX.Element {
  const [tab, setTab] = useState<RepresentationTabIndex>('information')

  return (
    <TabsContext.Provider
      value={{
        current: tab,
        switchToTab: (id: string) => setTab(id as RepresentationTabIndex),
      }}
    >
      <div className="tabs" role="tablist">
        <Tab id="information" context={TabsContext}>
          <GraphicalIcon icon="comment" />
          <Tab.Title text="information" />
        </Tab>
        <Tab id="scratchpad" context={TabsContext}>
          <GraphicalIcon icon="scratchpad" />
          <Tab.Title text="Scratchpad" />
        </Tab>
        <Tab id="guidance" context={TabsContext}>
          <GraphicalIcon icon="guidance" />
          <Tab.Title text="Guidance" />
        </Tab>
      </div>
      <Tab.Panel id="information" context={TabsContext}>
        <AutomationRules guidance={data.guidance} />
      </Tab.Panel>
      <Tab.Panel id="scratchpad" context={TabsContext}>
        <Scratchpad
          scratchpad={data.scratchpad}
          track={data.representation.track}
          exercise={data.representation.exercise}
        />
      </Tab.Panel>
      <Tab.Panel id="guidance" context={TabsContext}>
        <div>Guidance is coming soon!</div>
        {/* <Guidance
          notes={notes}
          mentorSolution={mentorSolution}
          exemplarFiles={exemplarFiles}
          language={track.highlightjsLanguage}
          links={links}
        /> */}
      </Tab.Panel>
    </TabsContext.Provider>
  )
}
