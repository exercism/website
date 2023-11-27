import { ReactElement } from 'react'

type Props = {
  length: number
  render: (index: number) => ReactElement
}

export function generateComponents({ length, render }: Props): ReactElement[] {
  return Array.from({ length }).map((_, idx) => render(idx))
}
