import React, { useCallback, createContext } from 'react'
import { MentoringRequest, Discussion, SessionProps } from '../Session'

type RequestContextType = {
  handleRequestLock: (request: MentoringRequest) => void
  handleDiscussionStart: (discussion: Discussion) => void
}

export const RequestContext = createContext<RequestContextType>({
  handleRequestLock: () => {},
  handleDiscussionStart: () => {},
})

export const RequestWrapper = ({
  session,
  setSession,
  children,
}: React.PropsWithChildren<{
  session: SessionProps
  setSession: (session: SessionProps) => void
}>): JSX.Element => {
  const handleRequestLock = useCallback(
    (request) => {
      setSession({ ...session, request: request })
    },
    [setSession, session]
  )

  const handleDiscussionStart = useCallback(
    (discussion) => {
      setSession({ ...session, discussion: discussion })
    },
    [setSession, session]
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
