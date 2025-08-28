import React, { useCallback, useEffect, useRef, useState } from 'react'
import { animate } from '@juliangarnierorg/anime-beta'
import { useCSSExercisePageStore } from './store/cssExercisePageStore'
import { CSSExercisePageContext } from './CSSExercisePageContext'
import { getDiffCanvasFromIframes } from './utils/getDiffCanvasFromIframes'
import { debounce } from 'lodash'

export function ActualOutput() {
  const context = React.useContext(CSSExercisePageContext)
  if (!context) {
    return null
  }
  const { actualIFrameRef, expectedReferenceIFrameRef, expectedIFrameRef } =
    context
  const {
    isDiffModeOn,
    setCurtainOpacity,
    curtainMode,
    diffMode,
    studentCodeHash,
  } = useCSSExercisePageStore()
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
    if (isDiffModeOn) return
    setCurtainOpacity(0.6)
  }, [isDiffModeOn])

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
    if (isDiffModeOn) return
    setCurtainOpacity(1)
  }, [curtainWidth, isDiffModeOn])

  const binaryDiffRef = useRef<HTMLCanvasElement | null>(null)

  const previousActualSnapshot = useRef<string | undefined>(undefined)

  useEffect(() => {
    async function populateCanvas(forceRedraw = false) {
      if (!isDiffModeOn || diffMode === 'gradual') return

      const actualIframe = actualIFrameRef.current
      const expectedIframe = expectedIFrameRef.current
      const canvas = binaryDiffRef.current

      if (!actualIframe || !expectedIframe || !canvas) return

      await Promise.all([
        waitForIframeLoad(actualIframe),
        waitForIframeLoad(expectedIframe),
      ])

      const actualDoc = actualIframe.contentDocument
      const currentActualSnapshot = getIframeSnapshot(actualDoc)

      if (
        !forceRedraw &&
        previousActualSnapshot.current === currentActualSnapshot
      ) {
        return
      }

      previousActualSnapshot.current = currentActualSnapshot

      const resultCanvas = await getDiffCanvasFromIframes(
        actualIFrameRef,
        expectedIFrameRef
      )

      if (resultCanvas) {
        canvas.width = resultCanvas.width
        canvas.height = resultCanvas.height

        const ctx = canvas.getContext('2d')
        if (ctx) {
          ctx.clearRect(0, 0, canvas.width, canvas.height)
          ctx.drawImage(resultCanvas, 0, 0)
        }
      }
    }

    populateCanvas()

    const debouncedResize = debounce(() => {
      if (!isDiffModeOn || diffMode === 'gradual') return
      populateCanvas(true)
    }, 500)

    window.addEventListener('resize', debouncedResize)

    return () => {
      window.removeEventListener('resize', debouncedResize)
      debouncedResize.cancel?.()
    }
  }, [isDiffModeOn, diffMode, studentCodeHash])

  return (
    <div className="p-12">
      <h3 className="mb-8 font-mono font-semibold">Your result</h3>
      <div
        ref={containerRef}
        className="css-render-actual"
        style={{
          filter:
            isDiffModeOn && diffMode === 'gradual'
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
            mixBlendMode:
              isDiffModeOn && diffMode === 'gradual' ? 'difference' : 'normal',
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
              zIndex: 10,
              display:
                curtainMode || (isDiffModeOn && diffMode === 'gradual')
                  ? 'block'
                  : 'none',
            }}
          />
          <canvas
            ref={binaryDiffRef}
            className="absolute top-0 left-0 h-full w-full pointer-events-none"
            style={{
              zIndex: 35,
              display: isDiffModeOn && diffMode === 'binary' ? 'block' : 'none',
            }}
          />
          {curtainMode && (
            <>
              {/* the curtain itself */}
              <div
                className="absolute top-0 right-0 h-full"
                style={{
                  width: `${curtainWidth}px`,
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

function waitForIframeLoad(iframe: HTMLIFrameElement): Promise<void> {
  return new Promise((resolve, reject) => {
    if (!iframe) {
      reject('No iframe element.')
      return
    }
    if (iframe.contentDocument?.readyState === 'complete') {
      // Already loaded
      resolve()
    } else {
      iframe.onload = () => resolve()
      iframe.onerror = (err) => reject(err)
    }
  })
}

function getIframeSnapshot(doc: Document | null): string {
  if (!doc) return ''

  const headHTML = doc.head?.innerHTML ?? ''
  const bodyHTML = doc.body?.innerHTML ?? ''

  return headHTML + bodyHTML
}
