import React from 'react'
import { SplitPane } from '../common'
import { LeftPane } from './representation/left-pane'
import { RightPane } from './representation/right-pane'

export function Representation(): JSX.Element {
  return (
    <div className="c-mentor-discussion">
      <SplitPane
        defaultLeftWidth="90%"
        leftMinWidth={550}
        rightMinWidth={625}
        id="mentoring-session"
        left={<LeftPane />}
        right={<RightPane />}
      />
    </div>
  )
}
