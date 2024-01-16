import React, {
  useState,
  useRef,
  useEffect,
  useCallback,
  useContext,
} from 'react'
import { useLocalStorage } from '../../utils/use-storage'
import { ScreenSizeContext } from '../mentoring/session/ScreenSizeContext'

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

  const { isBelowLgWidth = false } = useContext(ScreenSizeContext) || {}

  return (
    <div className={classNames} ref={splitPaneRef}>
      {!isBelowLgWidth && (
        <div
          className="--split-lhs"
          ref={leftRef}
          style={{ width: leftWidth, minWidth: leftMinWidth }}
        >
          {left}
        </div>
      )}
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
