import React from 'react'
import { SplitPane } from '../common/SplitPane'
import { CompleteRepresentationData } from '../types'
import { LeftPane } from './representation/left-pane'
import { RightPane } from './representation/right-pane'

export default function Representation({
  data,
}: {
  data: CompleteRepresentationData
}): JSX.Element {
  return (
    <div className="c-mentor-discussion">
      <SplitPane
        defaultLeftWidth="90%"
        leftMinWidth={550}
        rightMinWidth={625}
        id="mentoring-session"
        left={
          <LeftPane links={data.links} representation={data.representation} />
        }
        right={<RightPane data={data} />}
      />
    </div>
  )
}
