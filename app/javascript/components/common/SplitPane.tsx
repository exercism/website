import React, { useState, useRef, useEffect, useCallback } from 'react'

export const SplitPane = ({
  left,
  right,
}: {
  left: React.ReactNode
  right: React.ReactNode
}): JSX.Element => {
  const [dragging, setDragging] = useState(false)
  const leftRef = useRef<HTMLDivElement>(null)
  const splitPaneRef = useRef<HTMLDivElement>(null)

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

      leftRef.current.style.width = `${clientX}px`
    },
    [dragging]
  )

  const onMouseDown = useCallback(() => {
    setDragging(true)
  }, [])

  const onTouchStart = useCallback(() => {
    setDragging(true)
  }, [])

  const onMouseMove = useCallback(
    (e: MouseEvent) => {
      if (!dragging) {
        return
      }

      e.preventDefault()
      resizeLeft(e.clientX)
    },
    [dragging, resizeLeft]
  )

  const onTouchMove = useCallback(
    (e: TouchEvent) => {
      if (!dragging) {
        return
      }

      e.preventDefault()
      resizeLeft(e.touches[0].clientX)
    },
    [dragging, resizeLeft]
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
    <div className="c-split-pane" ref={splitPaneRef}>
      <div className="--split-lhs" ref={leftRef}>
        {left}
      </div>
      <div
        className="--split-divider"
        onMouseDown={onMouseDown}
        onTouchStart={onTouchStart}
        onTouchEnd={onMouseUp}
      />
      <div className="--split-rhs">{right}</div>
    </div>
  )
}
