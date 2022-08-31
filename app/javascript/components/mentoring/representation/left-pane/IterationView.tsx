import React from 'react'
import { Iteration, MentorDiscussion } from '../../../types'
import { FilePanel } from '../../session/FilePanel'
import { IterationHeader } from '../../session/iteration-view/IterationHeader'

export const IterationView = ({
  instructions,
  tests,
  currentIteration,
  language,
  indentSize,
  isOutOfDate,
  downloadCommand,
  // todo clean this up
  testData,
}: {
  iterations: readonly Iteration[]
  instructions?: string
  tests?: string
  currentIteration: Iteration
  onClick: (iteration: Iteration) => void
  language: string
  indentSize: number
  isOutOfDate: boolean
  isLinked: boolean
  setIsLinked: (linked: boolean) => void
  discussion?: MentorDiscussion
  downloadCommand: string
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  testData: any
}): JSX.Element => {
  const resolvedData = testData.representation

  return (
    <React.Fragment>
      <IterationHeader
        iteration={currentIteration}
        isOutOfDate={isOutOfDate}
        downloadCommand={downloadCommand}
        files={resolvedData?.files}
      />
      <FilePanel
        files={testData.representation.files}
        language={language}
        indentSize={indentSize}
        instructions={instructions}
        tests={tests}
      />
    </React.Fragment>
  )
}
