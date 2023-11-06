import React from 'react'
import { SplitPane } from '../common/SplitPane'
import { LeftPane } from './code-tagger/left-pane'
import { RightPane } from './code-tagger/right-pane'
import { CodeTaggerProps } from './code-tagger/CodeTagger.types'

export default function CodeTagger({
  code,
  links,
  tags,
}: CodeTaggerProps): JSX.Element {
  return (
    <div className="c-mentor-discussion code-tagger">
      <SplitPane
        defaultLeftWidth="90%"
        leftMinWidth={550}
        rightMinWidth={625}
        id="mentoring-session"
        left={<LeftPane code={code} links={links} />}
        right={<RightPane tags={tags} links={links} />}
      />
    </div>
  )
}
