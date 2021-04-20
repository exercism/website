import * as React from 'react'
import type { ReactNode } from 'react'

type WrapperProps = {
  children: ReactNode
  condition: boolean
  wrapper: (children: ReactNode) => ReactNode
}

export const Wrapper: React.FC<WrapperProps> = ({
  children,
  condition,
  wrapper,
}) => <>{condition ? wrapper(children) : children}</>
