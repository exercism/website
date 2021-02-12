import React, { useCallback, createContext } from 'react'
import { MentoringRequest, Discussion, SolutionProps } from '../Solution'

type RequestContextType = {
  handleRequestLock: (request: MentoringRequest) => void
  handleDiscussionStart: (discussion: Discussion) => void
}

export const RequestContext = createContext<RequestContextType>({
  handleRequestLock: () => {},
  handleDiscussionStart: () => {},
})

export const RequestWrapper = ({
  solution,
  setSolution,
  children,
}: React.PropsWithChildren<{
  solution: SolutionProps
  setSolution: (solution: SolutionProps) => void
}>): JSX.Element => {
  const handleRequestLock = useCallback(
    (request) => {
      setSolution({ ...solution, request: request })
    },
    [setSolution, solution]
  )

  const handleDiscussionStart = useCallback(
    (discussion) => {
      setSolution({ ...solution, discussion: discussion })
    },
    [setSolution, solution]
  )

  return (
    <RequestContext.Provider
      value={{
        handleRequestLock: handleRequestLock,
        handleDiscussionStart: handleDiscussionStart,
      }}
    >
      {children}
    </RequestContext.Provider>
  )
}
