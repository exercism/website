// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-nocheck
import React from 'react'
import { Iteration } from '../../../types'
import { CloseButton } from '../../session/CloseButton'
import { IterationView } from './IterationView'
import RepresentationInfo from './RepresentationInfo'

export type PanesProps = {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  exerciseData: any
  currentIteration: Iteration
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  handleIterationClick: (iteration: any) => void
  isLinked: boolean
  setIsLinked: () => void
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  data: any
}

export function LeftPane({
  data,
  exerciseData,
  currentIteration,
  handleIterationClick,
  isLinked,
  setIsLinked,
}: PanesProps): JSX.Element {
  return (
    <>
      <header className="discussion-header">
        <CloseButton url={''} />
        <RepresentationInfo
          exercise={exerciseData.exercise}
          track={exerciseData.track}
        />
      </header>
      <IterationView
        iterations={exerciseData.iterations}
        instructions={exerciseData.instructions}
        tests={exerciseData.tests}
        currentIteration={currentIteration}
        onClick={handleIterationClick}
        isOutOfDate={exerciseData.outOfDate}
        language={exerciseData.track.highlightjsLanguage}
        indentSize={exerciseData.track.indentSize}
        isLinked={isLinked}
        setIsLinked={setIsLinked}
        discussion={exerciseData.discussion}
        downloadCommand={exerciseData.downloadCommand}
      />
    </>
  )
}
