import React, { useRef } from 'react'
import { FrontendExercisePageContext } from '../../FrontendExercisePageContext'
import { useFrontendExercisePageStore } from '../../store/frontendExercisePageStore'

export function ActualOutput() {
  const context = React.useContext(FrontendExercisePageContext)
  if (!context) {
    return null
  }
  const { actualIFrameRef, expectedReferenceIFrameRef, expectedIFrameRef } =
    context
  const { isDiffActive } = useFrontendExercisePageStore()
  const containerRef = useRef<HTMLDivElement>(null)

  return (
    <div className="p-12">
      <h3 className="mb-8 font-mono font-semibold">Your result</h3>
      <div
        ref={containerRef}
        className="css-render-actual"
        style={{
          filter: isDiffActive
            ? 'sepia(100%) invert(100%) hue-rotate(116deg) brightness(110%)'
            : 'none',
          aspectRatio: context.code.aspectRatio,
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
        <>
          {/* the reference iframe - visually the same as `expected` */}
          <iframe
            className="absolute top-0 left-0 h-full w-full"
            ref={expectedReferenceIFrameRef}
            style={{
              zIndex: 10,
              display: isDiffActive ? 'block' : 'none',
            }}
          />
        </>
      </div>
    </div>
  )
}
