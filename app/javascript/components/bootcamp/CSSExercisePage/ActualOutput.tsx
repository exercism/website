import React, { useCallback, useRef, useState } from 'react'
import { animate } from '@juliangarnierorg/anime-beta'
import { useCSSExercisePageStore } from './store/cssExercisePageStore'
import { CSSExercisePageContext } from './CSSExercisePageContext'

export function ActualOutput() {
  const context = React.useContext(CSSExercisePageContext)
  if (!context) {
    return null
  }
  const { actualIFrameRef, expectedReferenceIFrameRef } = context
  const { diffMode, curtainOpacity, setCurtainOpacity, curtainMode } =
    useCSSExercisePageStore()
  const containerRef = useRef<HTMLDivElement>(null)
  // set a high number so curtain isn't at pos zero at first
  const [curtainWidth, setCurtainWidth] = useState(9999)

  const handleMouseMove = useCallback((e: React.MouseEvent) => {
    if (!containerRef.current) return
    const { left, width } = containerRef.current.getBoundingClientRect()
    const mouseX = e.clientX - left
    const newWidth = Math.max(0, Math.min(width - mouseX, width))
    setCurtainWidth(newWidth)
  }, [])

  const handleOnMouseEnter = useCallback(() => {
    if (diffMode) return
    setCurtainOpacity(0.6)
  }, [diffMode])

  const handleOnMouseLeave = useCallback(() => {
    if (!containerRef.current) return
    const { width } = containerRef.current.getBoundingClientRect()
    const curtain = { width: curtainWidth }
    animate(curtain, {
      width,
      duration: 250,
      ease: 'outQuint',
      onUpdate: () => {
        setCurtainWidth(curtain.width)
      },
    })
    if (diffMode) return
    setCurtainOpacity(1)
  }, [curtainWidth, diffMode])

  return (
    <div className="p-12">
      <h3 className="mb-12 font-mono font-semibold">Your code:</h3>
      <div
        ref={containerRef}
        className="css-render-actual"
        style={{
          filter: diffMode ? 'invert(1) hue-rotate(100deg)' : 'none',
        }}
      >
        {/* student's code's output */}
        <iframe
          className="absolute top-0 left-0 h-full w-full"
          ref={actualIFrameRef}
          style={{
            zIndex: 30,
            opacity: diffMode ? 1 : curtainOpacity,
            mixBlendMode: diffMode ? 'difference' : 'normal',
            clipPath: curtainMode
              ? `inset(0 0 0 calc(100% - ${curtainWidth}px))`
              : 'none',
          }}
        />
        <>
          {/* the reference iframe - visually the same as `expected` */}
          <iframe
            className="absolute top-0 left-0 h-full w-full"
            ref={expectedReferenceIFrameRef}
            style={{
              opacity: 1,
              zIndex: 10,
              display: curtainMode || diffMode ? 'block' : 'none',
            }}
          />
          {curtainMode && (
            <>
              {/* the curtain itself */}
              <div
                className="absolute top-0 right-0 h-full"
                style={{
                  width: `${curtainWidth}px`,
                  backgroundColor: `rgba(255, 255, 255, ${curtainOpacity})`,
                  zIndex: 25,
                  boxShadow: '-2px 0 0 #f22',
                }}
              />

              {/* mouse-capture area - otherwise mouse-move couldn't be properly captured */}
              <div
                className="absolute top-0 left-0 w-full h-full"
                onMouseMove={handleMouseMove}
                onMouseLeave={handleOnMouseLeave}
                onMouseEnter={handleOnMouseEnter}
                style={{ zIndex: 40 }}
              />
            </>
          )}
        </>
      </div>
    </div>
  )
}
