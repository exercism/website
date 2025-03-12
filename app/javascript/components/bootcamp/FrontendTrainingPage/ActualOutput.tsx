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
  const [curtainWidth, setCurtainWidth] = useState(350)
  const [curtainOpacity, setCurtainOpacity] = useState(1)
  const [diffMode, setDiffMode] = useState(false)

  const handleMouseMove = (e: React.MouseEvent) => {
    if (!containerRef.current) return

    const { left } = containerRef.current.getBoundingClientRect()
    const mouseX = e.clientX - left

    const newWidth = Math.max(0, Math.min(mouseX, width))
    setCurtainWidth(newWidth)
  }

  const handleOnMouseEnter = useCallback(() => {
    if (diffMode) return
    setCurtainOpacity(0.6)
  }, [diffMode])

  const handleOnMouseLeave = useCallback(() => {
    const curtain = { width: curtainWidth }
    animate(curtain, {
      width: 350,
      duration: 250,
      ease: 'outQuint',
      onUpdate: () => {
        setCurtainWidth(curtain.width)
      },
    })
    if (diffMode) return
    setCurtainOpacity(1)
  }, [curtainWidth])

  const toggleDiffMode = useCallback((diffState: boolean) => {
    setDiffMode(!diffState)
    diffState ? setCurtainOpacity(1) : setCurtainOpacity(0.3)
  }, [])

  return (
    <div className="p-12">
      <button
        onClick={() => toggleDiffMode(diffMode)}
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
        style={{ isolation: 'isolate' }}
      >
        <iframe
          className="absolute top-0 left-0 h-full w-full"
          ref={actualIFrameRef}
          style={{
            zIndex: 30,
            opacity: 1,
            mixBlendMode: diffMode ? 'difference' : 'normal',
            clipPath: `inset(0 ${width - curtainWidth}px 0 0)`,
          }}
        />

        <iframe
          className="absolute top-0 left-0 h-full w-full"
          ref={expectedReferenceIFrameRef}
          style={{
            opacity: 1,
            zIndex: 10,
          }}
        />

        <div
          className="absolute top-0 left-0 h-full"
          style={{
            boxShadow: `${curtainWidth}px 0 0 2px #f22, 2px 0 0 ${curtainWidth}px rgba(255, 255, 255, ${curtainOpacity})`,
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
