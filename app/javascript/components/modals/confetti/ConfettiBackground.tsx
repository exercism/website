import React, { useEffect, useRef } from 'react'
import { Confetti, type ConfettiOptions } from './Confetti'

const OPTIONS: ConfettiOptions = {
  colorPairs: [
    ['#df0049', '#660671'],
    ['#00e857', '#005291'],
    ['#2bebbc', '#05798a'],
    ['#ffd200', '#b06c00'],
  ],
  confettiPaperCount: 100,
  confettiRibbonCount: 40,
  speed: 30,
}

const prefersReducedMotion = () =>
  window.matchMedia?.('(prefers-reduced-motion: reduce)').matches ?? false

// Confetti that keeps falling behind a celebratory modal until it closes.
// It fills its parent element and restarts whenever the parent resizes.
export function ConfettiBackground(): JSX.Element {
  const canvasRef = useRef<HTMLCanvasElement>(null)

  useEffect(() => {
    const canvas = canvasRef.current
    const parent = canvas?.parentElement
    if (!canvas || !parent || prefersReducedMotion()) return

    let confetti: Confetti | null = null

    const start = () => {
      confetti?.stop()

      // The canvas is sized in CSS pixels, without devicePixelRatio, as it was
      // in @exercism/active-background. Confetti spreads its pieces over a
      // devicePixelRatio-scaled area, so scaling the canvas as well would make
      // the confetti several times denser on retina screens than it has been.
      canvas.style.width = `${parent.offsetWidth}px`
      canvas.style.height = `${parent.offsetHeight}px`
      canvas.width = parent.offsetWidth
      canvas.height = parent.offsetHeight

      confetti = new Confetti(canvas, OPTIONS)
      confetti.start()
    }

    // The observer also calls start once straight away
    const observer = new ResizeObserver(start)
    observer.observe(parent)

    return () => {
      observer.disconnect()
      confetti?.stop()
    }
  }, [])

  return (
    <canvas
      ref={canvasRef}
      aria-hidden="true"
      className="absolute top-0 left-0 pointer-events-none"
    />
  )
}
