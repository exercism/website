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

      // `clientX` is viewport-relative, so offset it by where the pane
      // starts. Clamping here (rather than relying on the panes' CSS
      // min-widths alone) keeps the stored width in step with the divider:
      // otherwise dragging past a limit keeps growing the number while the
      // divider stays put, and the cursor has to travel all the way back
      // before the pane responds again.
      const bounds = splitPaneRef.current.getBoundingClientRect()
      const maxLeft = bounds.width - rightMinWidth
      const nextLeft = clientX - bounds.left

      setLeftWidth(Math.min(Math.max(nextLeft, leftMinWidth), maxLeft))
    },
    [dragging, leftMinWidth, rightMinWidth]
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

  // A width persisted from a wider window (or from before a min-width was
  // introduced) can exceed what's available now. The right pane's own
  // min-width stops it collapsing, so cap the left pane to match rather than
  // letting the two disagree and overflow the container.
  const cappedLeftWidth =
    typeof leftWidth === 'number'
      ? `min(${leftWidth}px, 100% - ${rightMinWidth}px)`
      : leftWidth

  return (
    <div className={classNames} ref={splitPaneRef}>
      {!isBelowLgWidth && (
        <div
          className="--split-lhs"
          ref={leftRef}
          style={{ width: cappedLeftWidth, minWidth: leftMinWidth }}
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
