import { useEffect, useRef } from 'react'
export function useRestoreIframeScrollAfterResize() {
  const isDraggingRef = useRef(false)

  useEffect(() => {
    const resizer = document.querySelector<HTMLDivElement>(
      '.frontend-exercise-page-resizer'
    )

    if (!resizer) {
      return
    }
    const getIframeContainers = (): HTMLDivElement[] => {
      try {
        const expected = Array.from(
          document.querySelectorAll<HTMLDivElement>('.fe-render-expected') || []
        )
        const actual = Array.from(
          document.querySelectorAll<HTMLDivElement>('.fe-render-actual') || []
        )
        return [...expected, ...actual].filter(Boolean)
      } catch (error) {
        console.error('Error getting iframe containers:', error)
        return []
      }
    }

    const handleDragStart = (event: MouseEvent): void => {
      try {
        isDraggingRef.current = true

        getIframeContainers().forEach((container) => {
          if (container) {
            container.style.pointerEvents = 'none'
          }
        })
      } catch (error) {
        console.error('Error in drag start handler:', error)
      }
    }

    const handleDragEnd = (event: MouseEvent): void => {
      try {
        if (!isDraggingRef.current) return
        isDraggingRef.current = false

        getIframeContainers().forEach((container) => {
          if (container) {
            container.style.pointerEvents = 'auto'

            // Force repaint to restore scrollability
            container.style.display = 'none'
            requestAnimationFrame(() => {
              if (container) {
                container.style.display = ''
              }
            })
          }
        })
      } catch (error) {
        console.error('Error in drag end handler:', error)
      }
    }

    resizer.addEventListener('mousedown', handleDragStart)

    document.addEventListener('mouseup', handleDragEnd)

    document.addEventListener('mouseleave', handleDragEnd)

    return () => {
      resizer.removeEventListener('mousedown', handleDragStart)
      document.removeEventListener('mouseup', handleDragEnd)
      document.removeEventListener('mouseleave', handleDragEnd)
    }
  }, [])
}
