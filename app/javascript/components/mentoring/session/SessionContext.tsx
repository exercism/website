import React from 'react'
import { SessionProps } from '../Session'
import { DiscussionWrapper } from '../discussion/DiscussionContext'
import { RequestWrapper } from '../request/RequestContext'

export const SessionContext = ({
  session,
  setSession,
  children,
}: React.PropsWithChildren<{
  session: SessionProps
  setSession: (session: SessionProps) => void
}>): JSX.Element => {
  const Wrapper = session.discussion ? DiscussionWrapper : RequestWrapper

  return (
    <Wrapper session={session} setSession={setSession}>
      {children}
    </Wrapper>
  )
}
