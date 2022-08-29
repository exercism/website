import React, { useState } from 'react'
import { SplitPane } from '../common'
import { LeftPane } from './representation/left-pane'
import { RightPane } from './representation/right-pane'
import { RAW_SESSION_DATA } from './representation/mock-data'
import { useIterationScrolling } from './session/useIterationScrolling'

export function Representation(): JSX.Element {
  const [isLinked, setIsLinked] = useState(false)

  const { currentIteration, handleIterationClick } = useIterationScrolling({
    iterations: RAW_SESSION_DATA.iterations,
    on: isLinked,
  })

  return (
    <div className="c-mentor-discussion">
      <SplitPane
        defaultLeftWidth="90%"
        leftMinWidth={550}
        rightMinWidth={625}
        id="mentoring-session"
        left={
          <LeftPane
            exerciseData={RAW_SESSION_DATA}
            currentIteration={currentIteration}
            handleIterationClick={handleIterationClick}
            isLinked={isLinked}
            setIsLinked={() => setIsLinked((l) => !l)}
          />
        }
        right={
          <RightPane
            exerciseData={RAW_SESSION_DATA}
            currentIteration={currentIteration}
            handleIterationClick={handleIterationClick}
            isLinked={isLinked}
            setIsLinked={() => setIsLinked((l) => !l)}
          />
        }
      />
    </div>
  )
}
