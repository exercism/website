import React, { useCallback, useRef, useState } from 'react'
import { FrontendTrainingPageContext } from './FrontendTrainingPage'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { animate } from '@juliangarnierorg/anime-beta'

const width = 350

export function ActualOutput() {
  const context = React.useContext(FrontendTrainingPageContext)
  if (!context) {
    return null
  }
  const { actualIFrameRef, expectedReferenceIFrameRef } = context

  const containerRef = useRef<HTMLDivElement>(null)
  const [curtainWidth, setCurtainWidth] = useState(0)
  const [opacity, setOpacity] = useState(0)
  const [diffMode, setDiffMode] = useState(false)

  const handleMouseMove = (e: React.MouseEvent) => {
    if (!containerRef.current) return

    const { left } = containerRef.current.getBoundingClientRect()
    const mouseX = e.clientX - left

    const newWidth = Math.max(0, Math.min(mouseX, width))
    setCurtainWidth(newWidth)
  }

  const handleOnMouseEnter = useCallback(() => {
    setOpacity(1)
  }, [])

  const handleOnMouseLeave = useCallback(() => {
    const curtain = { width: curtainWidth }
    animate(curtain, {
      width: 350,
      duration: 250,
      ease: 'inExpo',
      onUpdate: () => {
        setCurtainWidth(curtain.width)
      },
    })
    setOpacity(0)
  }, [curtainWidth])

  return (
    <div className="p-12">
      <button
        onClick={() => setDiffMode((d) => !d)}
        className={assembleClassNames(
          'p-2 mb-4 border-1 border-borderColor1 rounded-3',
          diffMode ? 'bg-textColor6 text-white' : 'bg-white text-textColor1'
        )}
      >
        Diff mode
      </button>
      <h3 className="mb-12 font-mono font-semibold">Your code:</h3>
      <div
        ref={containerRef}
        className="border border-textColor1 border-1 rounded-12 w-[350px] h-[350px] relative overflow-hidden"
      >
        <iframe
          className="absolute top-0 left-0 h-full w-full"
          ref={actualIFrameRef}
          src=""
          frameBorder="0"
          style={{
            zIndex: 30,
            mixBlendMode: diffMode ? 'difference' : 'normal',
          }}
        />

        <iframe
          className="absolute top-0 left-0 h-full w-full"
          ref={expectedReferenceIFrameRef}
          style={{
            opacity: diffMode ? 1 : opacity,
            zIndex: 10,
            mixBlendMode: diffMode ? 'difference' : 'normal',
            transition: 'opacity 150ms',
          }}
        />

        <div
          className="absolute top-0 left-0 h-full"
          style={{
            boxShadow: `2px 0 0 ${curtainWidth}px rgba(255, 255, 255, 0.9)`,
            zIndex: 20,
          }}
        />

        <div
          className="absolute top-0 left-0 w-full h-full"
          onMouseMove={handleMouseMove}
          onMouseLeave={handleOnMouseLeave}
          onMouseEnter={handleOnMouseEnter}
          style={{ zIndex: 40 }}
        />
      </div>
    </div>
  )
}
