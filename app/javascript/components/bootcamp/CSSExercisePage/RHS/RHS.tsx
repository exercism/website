import React, { createContext } from 'react'
import { useCSSExercisePageStore } from '../store/cssExercisePageStore'
import { ActualOutput } from '../ActualOutput'
import { ExpectedOutput } from '../ExpectedOutput'
import { Instructions } from '../Instructions'

export function RHS() {
  const {
    panelSizes: { RHSWidth },
  } = useCSSExercisePageStore()
  return (
    <div className="page-body-rhs" style={{ width: RHSWidth }}>
      <div className="flex gap-8">
        <div className="flex flex-col gap-12">
          <ActualOutput />
          <ExpectedOutput />
        </div>

        <Instructions
          exerciseTitle="Css world!"
          exerciseInstructions="<div>Follow these instructions</div>"
        />
      </div>
    </div>
  )
}
