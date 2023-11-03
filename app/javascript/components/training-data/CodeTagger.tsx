import React from 'react'
import { SplitPane } from '../common/SplitPane'
import { LeftPane } from './code-tagger/left-pane'
import { RightPane } from './code-tagger/right-pane'
import type { CommunitySolution } from '../types'
import { useLogger } from '@/hooks'

type CodeTaggerFile = {
  filename: string
  code: string
}

type CodeTaggerProps = {
  files: CodeTaggerFile[]
  tags: Record<string, string>
}

export default function CodeTagger({
  data,
}: {
  data: CodeTaggerProps
}): JSX.Element {
  useLogger('data', data)
  return (
    <div className="c-mentor-discussion code-tagger">
      <SplitPane
        defaultLeftWidth="90%"
        leftMinWidth={550}
        rightMinWidth={625}
        id="mentoring-session"
        left={<LeftPane solution={data.files[0].code} />}
        right={<RightPane tags={data.tags} />}
      />
    </div>
  )
}
