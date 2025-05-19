import React, { useRef } from 'react'
import { FrontendExercisePageContext } from '../../../FrontendExercisePageContext'
import { useFrontendExercisePageStore } from '../../../store/frontendExercisePageStore'

export function ActualOutput() {
  const context = React.useContext(FrontendExercisePageContext)
  if (!context) {
    return null
  }
  const { actualIFrameRef, expectedReferenceIFrameRef } = context
  const { isDiffActive, isOverlayActive } = useFrontendExercisePageStore()
  const containerRef = useRef<HTMLDivElement>(null)

  return (
    <div
      ref={containerRef}
      className="fe-render-actual"
      style={{
        filter: isDiffActive
          ? 'sepia(100%) invert(100%) hue-rotate(116deg) brightness(110%)'
          : 'none',
      }}
    >
      {/* student's code's output */}
      <iframe
        className="absolute top-0 left-0 h-full w-full"
        ref={actualIFrameRef}
        style={{
          zIndex: 30,
          mixBlendMode: isDiffActive ? 'difference' : 'normal',
        }}
      />
      {/* the reference iframe - visually the same as `expected` */}
      <iframe
        className="absolute top-0 left-0 h-full w-full"
        ref={expectedReferenceIFrameRef}
        style={{
          zIndex: isOverlayActive ? 40 : 10,
          opacity: isOverlayActive ? 0.5 : 1,
          display: isDiffActive || isOverlayActive ? 'block' : 'none',
        }}
      />
    </div>
  )
}
