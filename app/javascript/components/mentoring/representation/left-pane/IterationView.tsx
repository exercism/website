import React from 'react'
import { ResultsZone } from '../../../ResultsZone'
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
  return (
    <React.Fragment>
      <IterationHeader
        iteration={currentIteration}
        isOutOfDate={isOutOfDate}
        downloadCommand={downloadCommand}
        files={testData.representation.files}
      />
      <ResultsZone isFetching={false}>
        <FilePanel
          files={testData.representation.files}
          language={testData.representation.track.title.toLowerCase()}
          indentSize={2}
          instructions={testData.representation.instructions}
          tests={testData.representation.tests}
        />
      </ResultsZone>
    </React.Fragment>
  )
}
