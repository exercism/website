import React from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { useLocalStorage } from '@uidotdev/usehooks'
import { useEffect, useRef, useState } from 'react'

type Direction = 'horizontal' | 'vertical'

type ResizableOptions = {
  initialSize: number
  direction: Direction
  localStorageId: string
  primaryMinSize?: number
  secondaryMinSize?: number
}

export function useResizablePanels({
  initialSize,
  direction,
  localStorageId,
  primaryMinSize = 250,
  secondaryMinSize = 250,
}: ResizableOptions) {
  const [primarySize, setPrimarySize] = useLocalStorage(
    localStorageId,
    initialSize
  )
  const [secondarySize, setSecondarySize] = useState(
    (direction === 'horizontal' ? window.innerWidth : window.innerHeight) -
      primarySize
  )

  const startSizeRef = useRef(primarySize)

  const handleMouseDown = (e: React.MouseEvent<HTMLButtonElement>) => {
    const containerSize =
      direction === 'horizontal' ? window.innerWidth : window.innerHeight
    const startCoordinate = direction === 'horizontal' ? e.clientX : e.clientY

    startSizeRef.current = primarySize

    const handleMouseMove = (moveEvent: MouseEvent) => {
      const currentCoordinate =
        direction === 'horizontal' ? moveEvent.clientX : moveEvent.clientY
      const delta = currentCoordinate - startCoordinate
      const newPrimarySize = Math.max(
        primaryMinSize,
        Math.min(startSizeRef.current + delta, containerSize - secondaryMinSize)
      )

      setPrimarySize(newPrimarySize)
      setSecondarySize(containerSize - newPrimarySize)
    }

    const handleMouseUp = () => {
      document.removeEventListener('mousemove', handleMouseMove)
      document.removeEventListener('mouseup', handleMouseUp)
    }

    document.addEventListener('mousemove', handleMouseMove)
    document.addEventListener('mouseup', handleMouseUp)
  }

  const handleResize = () => {
    const containerSize =
      direction === 'horizontal' ? window.innerWidth : window.innerHeight

    const newPrimarySize = Math.min(primarySize, containerSize - 300)
    setPrimarySize(newPrimarySize)
    setSecondarySize(containerSize - newPrimarySize)
  }

  useEffect(() => {
    window.addEventListener('resize', handleResize)

    return () => {
      window.removeEventListener('resize', handleResize)
    }
  }, [primarySize, direction])

  return {
    primarySize,
    secondarySize,
    handleMouseDown,
  }
}

export function Resizer({
  handleMouseDown,
  direction,
}: {
  handleMouseDown: (e: React.MouseEvent<HTMLButtonElement>) => void
  direction: Direction
}) {
  return (
    <button
      onMouseDown={handleMouseDown}
      className={assembleClassNames(
        'p-[2px] active:bg-slate-100 ',
        direction === 'horizontal' ? 'cursor-row-resize' : 'cursor-col-resize'
      )}
    >
      {direction === 'vertical' ? '⋮' : '⋯'}
    </button>
  )
}
