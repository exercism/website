import React from 'react'
import { PanesProps } from '../left-pane/LeftPane'
import AutomationRules from './AutomationRules'
import HowImportant from './HowImportant'
import MentoringConversation from './MentoringConversation'

export function RightPane({
  exerciseData,
  currentIteration,
  handleIterationClick,
  isLinked,
  setIsLinked,
}: PanesProps): JSX.Element {
  return (
    <div className="!h-100 py-16 flex flex-col justify-between">
      <div className="flex flex-col">
        <AutomationRules />
        <HowImportant />
      </div>
      <MentoringConversation
        currentIteration={currentIteration}
        exerciseData={exerciseData}
        handleIterationClick={handleIterationClick}
        setIsLinked={setIsLinked}
        isLinked={isLinked}
      />
    </div>
  )
}
