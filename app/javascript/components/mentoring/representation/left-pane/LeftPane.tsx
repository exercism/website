// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-nocheck
import React, { useState } from 'react'
import { CloseButton } from '../../session/CloseButton'
import { IterationView } from '../../session/IterationView'
import { useIterationScrolling } from '../../session/useIterationScrolling'
import { RAW_SESSION_DATA } from '../mock-data'
import RepresentationInfo from './RepresentationInfo'

export function LeftPane(): JSX.Element {
  const [isLinked, setIsLinked] = useState(false)

  const { currentIteration, handleIterationClick } = useIterationScrolling({
    iterations: RAW_SESSION_DATA.iterations,
    on: isLinked,
  })
  return (
    <>
      <header className="discussion-header">
        <CloseButton url={'somewhere'} />
        <RepresentationInfo
          exercise={RAW_SESSION_DATA.exercise}
          track={RAW_SESSION_DATA.track}
        />
      </header>
      <IterationView
        iterations={RAW_SESSION_DATA.iterations}
        instructions={RAW_SESSION_DATA.instructions}
        tests={RAW_SESSION_DATA.tests}
        currentIteration={currentIteration}
        onClick={handleIterationClick}
        isOutOfDate={RAW_SESSION_DATA.outOfDate}
        language={RAW_SESSION_DATA.track.highlightjsLanguage}
        indentSize={RAW_SESSION_DATA.track.indentSize}
        isLinked={isLinked}
        setIsLinked={() => setIsLinked((t) => !t)}
        discussion={RAW_SESSION_DATA.discussion}
        downloadCommand={RAW_SESSION_DATA.downloadCommand}
      />
    </>
  )
}
