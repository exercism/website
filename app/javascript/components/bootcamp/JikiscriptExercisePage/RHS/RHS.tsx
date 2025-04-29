import { assembleClassNames } from '@/utils/assemble-classnames'
import React, { useContext } from 'react'
import { Instructions } from './Instructions/Instructions'
import { Logger } from './Logger/Logger'
import { JikiscriptExercisePageContext } from '../JikiscriptExercisePageContextWrapper'
import { Resizer, useResizablePanels } from '../hooks/useResize'

export function RHS({ width }: { width: number }) {
  const { exercise } = useContext(JikiscriptExercisePageContext)
  const {
    primarySize: TopHeight,
    secondarySize: BottomHeight,
    handleMouseDown: handleHeightChangeMouseDown,
  } = useResizablePanels({
    initialSize: 200,
    secondaryMinSize: 200,
    direction: 'vertical',
    localStorageId: 'solve-exercise-page-rhs-height',
  })
  return (
    <div className={assembleClassNames('page-body-rhs')} style={{ width }}>
      <Instructions
        exerciseTitle={exercise.title}
        exerciseInstructions={exercise.introductionHtml}
        height={exercise.language === 'javascript' ? TopHeight : '100%'}
      />

      {exercise.language === 'javascript' && (
        <>
          <Resizer
            direction="horizontal"
            handleMouseDown={handleHeightChangeMouseDown}
            className="c-logger-resizer"
          />
          <Logger height={BottomHeight} />
        </>
      )}
    </div>
  )
}
