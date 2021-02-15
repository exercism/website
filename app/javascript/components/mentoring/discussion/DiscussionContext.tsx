import React, {
  useCallback,
  createContext,
  useEffect,
  useRef,
  useState,
} from 'react'
import { Discussion, SessionProps } from '../Session'

type DiscussionContextType = {
  handleFinish: (discussion: Discussion) => void
  previouslyNotFinishedRef: React.MutableRefObject<boolean>
  finishedWizardRef: React.MutableRefObject<HTMLDivElement | null>
}

export const DiscussionContext = createContext<DiscussionContextType>({
  handleFinish: () => {},
  previouslyNotFinishedRef: { current: false },
  finishedWizardRef: { current: null },
})

type PostsContextType = {
  cacheKey: string
  hasNewMessages: boolean
  setHasNewMessages: (value: boolean) => void
  highlightedPostRef: React.MutableRefObject<HTMLDivElement | null>
}

export const PostsContext = createContext<PostsContextType>({
  cacheKey: '',
  hasNewMessages: false,
  setHasNewMessages: () => {},
  highlightedPostRef: { current: null },
})

export const PostsWrapper = ({
  cacheKey,
  children,
}: React.PropsWithChildren<{ cacheKey: string }>): JSX.Element => {
  const [hasNewMessages, setHasNewMessages] = useState(false)
  const highlightedPostRef = useRef<HTMLDivElement | null>(null)

  return (
    <PostsContext.Provider
      value={{
        cacheKey,
        hasNewMessages,
        setHasNewMessages,
        highlightedPostRef,
      }}
    >
      {children}
    </PostsContext.Provider>
  )
}

export const DiscussionWrapper = ({
  session,
  setSession,
  children,
}: React.PropsWithChildren<{
  session: SessionProps
  setSession: (session: SessionProps) => void
}>): JSX.Element => {
  const previouslyNotFinishedRef = useRef(!session.discussion.isFinished)
  const finishedWizardRef = useRef<HTMLDivElement>(null)

  const handleFinish = useCallback(
    (discussion) => {
      setSession({ ...session, discussion: discussion })
    },
    [setSession, session]
  )

  useEffect(() => {
    if (!finishedWizardRef.current) {
      return
    }

    finishedWizardRef.current.scrollIntoView()
  }, [session.relationship])

  return (
    <DiscussionContext.Provider
      value={{
        handleFinish,
        previouslyNotFinishedRef,
        finishedWizardRef,
      }}
    >
      <PostsWrapper cacheKey={`posts-discussion-${session.discussion.id}`}>
        {children}
      </PostsWrapper>
    </DiscussionContext.Provider>
  )
}
