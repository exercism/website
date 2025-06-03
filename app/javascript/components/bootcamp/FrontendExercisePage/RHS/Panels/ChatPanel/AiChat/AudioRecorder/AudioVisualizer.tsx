import React, { useRef, useEffect, useState, useCallback } from 'react'

type AudioVisualizerProps = {
  analyser: AnalyserNode | null
}

function AudioVisualizer({ analyser }: AudioVisualizerProps): JSX.Element {
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const containerRef = useRef<HTMLDivElement>(null)
  const animationFrameId = useRef<number>()
  const [canvasWidth, setCanvasWidth] = useState(300)

  const updateCanvasSize = useCallback(() => {
    if (containerRef.current) {
      const { width } = containerRef.current.getBoundingClientRect()
      setCanvasWidth(Math.floor(width))
    }
  }, [])

  useEffect(() => {
    const observer = new ResizeObserver(updateCanvasSize)
    if (containerRef.current) {
      observer.observe(containerRef.current)
    }
    updateCanvasSize()
    return () => observer.disconnect()
  }, [updateCanvasSize])

  useEffect(() => {
    if (!analyser || !canvasRef.current) return

    const canvas = canvasRef.current
    const ctx = canvas.getContext('2d')
    if (!ctx) return

    const height = 26
    const bufferLength = analyser.fftSize
    const dataArray = new Uint8Array(bufferLength)

    ctx.lineWidth = 2
    ctx.strokeStyle = '#5C5589'

    const draw = () => {
      if (!analyser || !canvasRef.current) return

      analyser.getByteTimeDomainData(dataArray)

      ctx.clearRect(0, 0, canvas.width, height)
      ctx.beginPath()

      const sliceWidth = canvas.width / bufferLength
      let x = 0

      for (let i = 0; i < bufferLength; i++) {
        const v = dataArray[i] / 128.0
        const y = (v * height) / 2
        i === 0 ? ctx.moveTo(x, y) : ctx.lineTo(x, y)
        x += sliceWidth
      }

      ctx.stroke()
      animationFrameId.current = requestAnimationFrame(draw)
    }

    analyser.fftSize = 1024
    analyser.smoothingTimeConstant = 0.7
    draw()

    return () => {
      if (animationFrameId.current)
        cancelAnimationFrame(animationFrameId.current)
    }
  }, [analyser, canvasWidth])

  return (
    <div
      ref={containerRef}
      style={{
        width: '100%',
        borderRadius: '8px',
        overflow: 'hidden',
      }}
    >
      <canvas
        ref={canvasRef}
        width={canvasWidth}
        height={26}
        style={{
          width: '100%',
          height: '26px',
          display: 'block',
        }}
      />
    </div>
  )
}

export default AudioVisualizer
