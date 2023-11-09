import React from 'react'
import { SplitPane } from '../common/SplitPane'
import { LeftPane } from './code-tagger/left-pane/LeftPane'
import { RightPane } from './code-tagger/right-pane/RightPane'
import { CodeTaggerProps } from './code-tagger/CodeTagger.types'

export default function CodeTagger({
  code,
  links,
  sample,
}: CodeTaggerProps): JSX.Element {
  return (
    <div className="c-mentor-discussion code-tagger">
      <SplitPane
        defaultLeftWidth="90%"
        leftMinWidth={550}
        rightMinWidth={625}
        id="mentoring-session"
        left={<LeftPane code={code} links={links} />}
        right={
          <RightPane
            allEnabledTrackTags={code.track.tags}
            tags={sample.tags}
            links={links}
          />
        }
      />
    </div>
  )
}
