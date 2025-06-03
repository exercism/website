import React, { useEffect, useRef, useState, useCallback } from 'react'

type AudioVisualizerProps = {
  analyser: AnalyserNode | null
}

function AudioVisualizer({ analyser }: AudioVisualizerProps): JSX.Element {
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const containerRef = useRef<HTMLDivElement>(null)
  const animationFrameId = useRef<number>()
  const [canvasSize, setCanvasSize] = useState({ width: 300, height: 26 })

  const updateCanvasSize = useCallback(() => {
    if (containerRef.current) {
      const { width } = containerRef.current.getBoundingClientRect()
      setCanvasSize({ width: Math.floor(width), height: 26 })
    }
  }, [])

  useEffect(() => {
    const resizeObserver = new ResizeObserver(updateCanvasSize)
    if (containerRef.current) {
      resizeObserver.observe(containerRef.current)
    }

    updateCanvasSize()

    return () => {
      resizeObserver.disconnect()
    }
  }, [updateCanvasSize])

  const drawWaveform = useCallback(() => {
    if (!canvasRef.current || !analyser) return

    const canvas = canvasRef.current
    const ctx = canvas.getContext('2d')
    if (!ctx) return

    const width = canvas.width
    const height = canvas.height
    const bufferLength = analyser.frequencyBinCount
    const dataArray = new Uint8Array(bufferLength)

    analyser.getByteTimeDomainData(dataArray)

    ctx.fillStyle = 'rgb(255, 255, 255)'
    ctx.fillRect(0, 0, width, height)

    ctx.lineWidth = 2
    ctx.strokeStyle = 'rgb(0, 0, 0)'
    ctx.beginPath()

    const sliceWidth = width / bufferLength
    let x = 0

    for (let i = 0; i < bufferLength; i++) {
      const normalizedValue = (dataArray[i] - 128) / 128.0
      const amplified = normalizedValue * 3
      const y = height / 2 + (amplified * height) / 2

      if (i === 0) {
        ctx.moveTo(x, y)
      } else {
        ctx.lineTo(x, y)
      }

      x += sliceWidth
    }

    ctx.lineTo(canvas.width, canvas.height / 2)
    ctx.stroke()

    animationFrameId.current = requestAnimationFrame(drawWaveform)
  }, [analyser])

  useEffect(() => {
    if (analyser) {
      drawWaveform()
    }

    return () => {
      if (animationFrameId.current) {
        cancelAnimationFrame(animationFrameId.current)
      }
    }
  }, [analyser, drawWaveform])

  return (
    <div ref={containerRef} style={{ width: '100%' }}>
      <canvas
        ref={canvasRef}
        width={canvasSize.width}
        height={canvasSize.height}
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
