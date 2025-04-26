import React from 'react'
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
      <div className="flex gap-8 h-full">
        <div className="flex flex-col gap-12">
          <ExpectedOutput />
          <ActualOutput />
        </div>

        <div className="h-100 overflow-auto">
          <Instructions />
        </div>
      </div>
    </div>
  )
}
