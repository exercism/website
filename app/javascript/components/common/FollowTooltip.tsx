import React, {
  createContext,
  useContext,
  useState,
  useRef,
  useEffect,
} from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'

type TooltipContextType = { x: number | null }

const TooltipContext = createContext<TooltipContextType>({ x: null })

export function TooltipWrapper({
  children,
  className,
}: {
  children: React.ReactNode
  className?: string
}) {
  const [x, setX] = useState<number | null>(null)
  const ref = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      if (!ref.current) return
      const rect = ref.current.getBoundingClientRect()
      setX(e.clientX - rect.left)
    }

    const el = ref.current
    el?.addEventListener('mousemove', handleMouseMove)
    return () => el?.removeEventListener('mousemove', handleMouseMove)
  }, [])

  return (
    <TooltipContext.Provider value={{ x }}>
      <div
        ref={ref}
        className={assembleClassNames('relative group', className)}
      >
        {children}
      </div>
    </TooltipContext.Provider>
  )
}

export function useTooltipPosition() {
  return useContext(TooltipContext)
}

export function TooltipContent({
  children,
  className,
  style,
}: {
  children: React.ReactNode
  className?: string
  style?: React.CSSProperties
}) {
  const { x } = useTooltipPosition()

  if (x == null) return null

  return (
    <div
      style={{ left: x, ...style }}
      data-testid="follow-tooltip"
      className={assembleClassNames(
        'absolute -top-10 -translate-x-1/2 -translate-y-[calc(100%+8px)] hidden group-hover:block z-tooltip',
        className
      )}
      role="tooltip"
    >
      {children}
    </div>
  )
}
