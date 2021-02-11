import React from 'react'
import { SolutionProps } from '../Solution'
import { DiscussionWrapper } from '../discussion/DiscussionContext'

export const SolutionContext = ({
  solution,
  setSolution,
  children,
}: React.PropsWithChildren<{
  solution: SolutionProps
  setSolution: (solution: SolutionProps) => void
}>): JSX.Element => {
  const Wraooer = solution.discussion ? DiscussionWrapper : GenericWrapper

  return (
    <Wraooer solution={solution} setSolution={setSolution}>
      {children}
    </Wraooer>
  )
}

const GenericWrapper = ({
  children,
}: React.PropsWithChildren<{
  solution: SolutionProps
  setSolution: (solution: SolutionProps) => void
}>) => {
  return <React.Fragment>{children}</React.Fragment>
}
