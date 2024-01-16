import { ReactElement } from 'react'

type Props = {
  times: number
  render: (index: number) => ReactElement
}

export function repeatComponents({ times, render }: Props): ReactElement[] {
  return Array.from({ length: times }).map((_, idx) => render(idx))
}
