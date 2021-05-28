import React, { useState, useRef, useEffect, useCallback } from 'react'

export const SplitPane = ({
  left,
  right,
}: {
  left: React.ReactNode
  right: React.ReactNode
}): JSX.Element => {
  const [leftWidth, setLeftWidth] = useState(0)
  const [dragging, setDragging] = useState(false)
  const [dividerX, setDividerX] = useState<undefined | number>(undefined)
  const leftRef = useRef<HTMLDivElement>(null)
  const splitPaneRef = useRef<HTMLDivElement>(null)

  const resizeLeft = useCallback(
    (clientX: number) => {
      if (!dragging) {
        return
      }

      if (!dividerX) {
        return
      }

      if (!splitPaneRef.current) {
        return
      }

      const newLeftWidth = leftWidth + clientX - dividerX
      const splitPaneWidth = splitPaneRef.current.clientWidth

      setDividerX(clientX)

      setLeftWidth(newLeftWidth)
    },
    [dividerX, dragging, leftWidth]
  )

  const onMouseDown = useCallback((e: React.MouseEvent) => {
    setDividerX(e.clientX)
    setDragging(true)
  }, [])

  const onTouchStart = useCallback((e: React.TouchEvent) => {
    setDividerX(e.touches[0].clientX)
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
    setDividerX(undefined)
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

  useEffect(() => {
    if (!leftRef.current) {
      return
    }

    if (leftWidth) {
      return
    }

    setLeftWidth(leftRef.current.clientWidth)
  }, [leftRef, leftWidth, setLeftWidth])

  useEffect(() => {
    if (!leftRef.current) {
      return
    }

    leftRef.current.style.width = `${leftWidth}px`
  }, [leftWidth])

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
