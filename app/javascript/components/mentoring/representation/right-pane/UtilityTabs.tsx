import { AnalyzerFeedback } from '@/components/student/iterations-list/AnalyzerFeedback'
import React, { useState } from 'react'
import { Tab, GraphicalIcon } from '../../../common'
import { CompleteRepresentationData } from '../../../types'
import { TabsContext } from '../../Session'
import { Guidance } from '../../session/Guidance'
// import { Guidance } from '../../session/Guidance'
import { Scratchpad } from '../../session/Scratchpad'
import AutomationRules from './AutomationRules'
import Considerations from './Considerations'

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
          <Tab.Title text="Information" />
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
        <Considerations guidance={data.guidance} />
        <AutomationRules guidance={data.guidance} />

        {data.analyzerFeedback && (
          <div className="mx-24 my-16 border-t-2 border-borderColor6 pt-16 ">
            <AnalyzerFeedback
              summary={data.analyzerFeedback.summary}
              comments={data.analyzerFeedback.comments}
              automatedFeedbackInfoLink={'???'}
              track={data.representation.track}
            />
          </div>
        )}
      </Tab.Panel>
      <Tab.Panel id="scratchpad" context={TabsContext}>
        <Scratchpad
          scratchpad={data.scratchpad}
          track={data.representation.track}
          exercise={data.representation.exercise}
        />
      </Tab.Panel>
      <Tab.Panel id="guidance" context={TabsContext}>
        <Guidance
          guidance={data.guidance}
          mentorSolution={data.mentorSolution}
          exemplarFiles={data.guidance.exemplarFiles}
          language={data.representation.track.highlightjsLanguage}
          links={data.guidance.links}
        />
      </Tab.Panel>
    </TabsContext.Provider>
  )
}
