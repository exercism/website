import React, { useState, useRef, useEffect, useCallback } from 'react'
import { useLocalStorage } from '../../utils/use-storage'

export const SplitPane = ({
  id,
  left,
  right,
  className = '',
  leftMinWidth = 100,
  rightMinWidth = 100,
  defaultLeftWidth,
}: {
  id: string
  left: React.ReactNode
  right: React.ReactNode
  className?: string
  leftMinWidth?: number
  rightMinWidth?: number
  defaultLeftWidth?: string | number
}): JSX.Element => {
  const [leftWidth, setLeftWidth] = useLocalStorage<
    string | number | undefined
  >(`split-pane-${id}`, defaultLeftWidth)
  const [dragging, setDragging] = useState(false)
  const leftRef = useRef<HTMLDivElement>(null)
  const splitPaneRef = useRef<HTMLDivElement>(null)
  const classNames = ['c-split-pane', className]
    .filter((className) => className.length > 0)
    .join(' ')

  const resizeLeft = useCallback(
    (clientX: number) => {
      if (!dragging) {
        return
      }

      if (!splitPaneRef.current) {
        return
      }

      if (!leftRef.current) {
        return
      }

      setLeftWidth(clientX)
    },
    [dragging]
  )

  const onMouseDown = useCallback((e: React.MouseEvent) => {
    setDragging(true)
  }, [])

  const onTouchStart = useCallback((e: React.TouchEvent) => {
    setDragging(true)
  }, [])

  const onMouseMove = useCallback(
    (e: MouseEvent) => {
      e.preventDefault()
      resizeLeft(e.clientX)
    },
    [resizeLeft]
  )

  const onTouchMove = useCallback(
    (e: TouchEvent) => {
      e.preventDefault()
      resizeLeft(e.touches[0].clientX)
    },
    [resizeLeft]
  )

  const onMouseUp = useCallback(() => {
    setDragging(false)
  }, [])

  useEffect(() => {
    document.addEventListener('mousemove', onMouseMove)
    document.addEventListener('touchmove', onTouchMove)
    document.addEventListener('mouseup', onMouseUp)

    return () => {
      document.removeEventListener('mousemove', onMouseMove)
      document.removeEventListener('touchmove', onTouchMove)
      document.removeEventListener('mouseup', onMouseUp)
    }
  }, [onMouseMove, onTouchMove, onMouseUp])

  return (
    <div className={classNames} ref={splitPaneRef}>
      <div
        className="--split-lhs"
        ref={leftRef}
        style={{ width: leftWidth, minWidth: leftMinWidth }}
      >
        {left}
      </div>
      <div
        className="--split-divider"
        onMouseDown={onMouseDown}
        onTouchStart={onTouchStart}
        onTouchEnd={onMouseUp}
      />
      <div className="--split-rhs" style={{ minWidth: rightMinWidth }}>
        {right}
      </div>
    </div>
  )
}
