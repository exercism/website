import React from 'react'
import { SolutionProps } from '../Solution'
import { DiscussionWrapper } from '../discussion/DiscussionContext'
import { RequestWrapper } from '../request/RequestContext'

export const SolutionContext = ({
  solution,
  setSolution,
  children,
}: React.PropsWithChildren<{
  solution: SolutionProps
  setSolution: (solution: SolutionProps) => void
}>): JSX.Element => {
  const Wraooer = solution.discussion ? DiscussionWrapper : RequestWrapper

  return (
    <Wraooer solution={solution} setSolution={setSolution}>
      {children}
    </Wraooer>
  )
}
