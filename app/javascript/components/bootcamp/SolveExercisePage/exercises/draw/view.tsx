import React from 'react'
import { useEffect, useState } from 'react'
import { aToR } from './utils'

export function DrawView() {
  const [coordinates, setCoordinates] = useState({
    x: 0,
    y: 0,
    rawX: 0,
    rawY: 0,
  })

  const handleMouseMove = (
    event: React.MouseEvent<HTMLDivElement, MouseEvent>
  ) => {
    const rect = event.currentTarget.getBoundingClientRect()
    const x = event.clientX - rect.left
    const y = event.clientY - rect.top

    setCoordinates({
      x: aToR(Math.round(x)),
      y: aToR(Math.round(y)),
      rawX: Math.round(x),
      rawY: Math.round(y),
    })
  }

  useEffect(() => {
    return () => {
      const canvas = document.getElementById('drawing-canvas')
      if (canvas) {
        canvas.innerHTML = ''
      }
    }
  }, [])

  return (
    <div className="flex flex-col gap-8">
      <div
        id="drawing-canvas"
        style={{
          position: 'relative',
          width: '100%',
          height: '100%',
          backgroundColor: '#fafaff',
        }}
        onMouseMove={handleMouseMove}
      />
      <div>
        Relative coordinates: {coordinates.x}, {coordinates.y}
        <br />
        Absolute coordinates: {coordinates.rawX}, {coordinates.rawY}
      </div>
    </div>
  )
}
