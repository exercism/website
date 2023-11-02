import React from 'react'
import { SplitPane } from '../common/SplitPane'
import { LeftPane } from './solution-tagger/left-pane'
import { RightPane } from './solution-tagger/right-pane'
import type { CommunitySolution } from '../types'
import { useLogger } from '@/hooks'

type SolutionTaggerProps = {
  solution: CommunitySolution
  tags: Record<string, string>
}

export default function SolutionTagger({
  data,
}: {
  data: SolutionTaggerProps
}): JSX.Element {
  useLogger('data', data)
  return (
    <div className="c-mentor-discussion solution-tagger">
      <SplitPane
        defaultLeftWidth="90%"
        leftMinWidth={550}
        rightMinWidth={625}
        id="mentoring-session"
        left={<LeftPane solution={data.solution} />}
        right={<RightPane tags={data.tags} />}
      />
    </div>
  )
}
