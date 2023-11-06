import React from 'react'

const toggledOnStyle =
  'border-darkGreen text-everyoneLovesAGreen bg-[var(--backgroundColorConceptMastered)]'
const toggledOffStyle =
  'border-red text-red bg-[(var(--backgroundColorExerciseStatusTagLocked)]'

export function TagTogglerButton({
  isActive,
  onClick,
}: {
  isActive: boolean
  onClick: () => void
}) {
  return (
    <button
      onClick={onClick}
      className={`c-tag px-12 py-4 flex ${
        isActive ? toggledOnStyle : toggledOffStyle
      }`}
    >
      {isActive ? 'Yes' : 'No'}
    </button>
  )
}
