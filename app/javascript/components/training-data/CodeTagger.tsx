import React from 'react'
import { SplitPane } from '../common/SplitPane'
import { LeftPane } from './code-tagger/left-pane'
import { RightPane } from './code-tagger/right-pane'
import { CodeTaggerProps } from './code-tagger/SolutionTagger.types'

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
        left={<LeftPane solution={code.files[0]} />}
        right={<RightPane links={links} tags={tags} />}
      />
    </div>
  )
}
