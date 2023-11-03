import React from 'react'
import { SplitPane } from '../common/SplitPane'
import { LeftPane } from './solution-tagger/left-pane'
import { RightPane } from './solution-tagger/right-pane'
import { SolutionTaggerProps } from './solution-tagger/SolutionTagger.types'

export default function SolutionTagger({
  solution,
  links,
  tags,
}: SolutionTaggerProps): JSX.Element {
  return (
    <div className="c-mentor-discussion solution-tagger">
      <SplitPane
        defaultLeftWidth="90%"
        leftMinWidth={550}
        rightMinWidth={625}
        id="mentoring-session"
        left={<LeftPane solution={solution} />}
        right={<RightPane links={links} tags={tags} />}
      />
    </div>
  )
}
