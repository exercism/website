import React, {
  useState,
  useCallback,
  createContext,
  useEffect,
  useRef,
} from 'react'
import { Discussion, SessionProps } from '../Session'
import { DiscussionPostProps } from './DiscussionPost'

type DiscussionContextType = {
  cacheKey: string
  hasNewMessages: boolean
  handlePostsChange: (posts: DiscussionPostProps[]) => void
  handlePostHighlight: (element: HTMLDivElement) => void
  handleAfterPostHighlight: () => void
  handleFinish: (discussion: Discussion) => void
  highlightedPost: DiscussionPostProps | null
  highlightedPostRef: React.MutableRefObject<HTMLDivElement | null>
  previouslyNotFinishedRef: React.MutableRefObject<boolean>
  finishedWizardRef: React.MutableRefObject<HTMLDivElement | null>
}

export const DiscussionContext = createContext<DiscussionContextType>({
  cacheKey: '',
  hasNewMessages: false,
  handlePostsChange: () => {},
  handlePostHighlight: () => {},
  handleAfterPostHighlight: () => {},
  handleFinish: () => {},
  highlightedPost: null,
  highlightedPostRef: { current: null },
  previouslyNotFinishedRef: { current: false },
  finishedWizardRef: { current: null },
})

export const DiscussionWrapper = ({
  session,
  setSession,
  children,
}: React.PropsWithChildren<{
  session: SessionProps
  setSession: (session: SessionProps) => void
}>): JSX.Element => {
  const [hasNewMessages, setHasNewMessages] = useState(false)
  const [
    highlightedPost,
    setHighlightedPost,
  ] = useState<DiscussionPostProps | null>(null)
  const highlightedPostRef = useRef<HTMLDivElement | null>(null)
  const hasLoadedRef = useRef(false)

  const previouslyNotFinishedRef = useRef(!session.discussion.isFinished)
  const finishedWizardRef = useRef<HTMLDivElement>(null)

  const handlePostsChange = useCallback(
    (posts) => {
      if (!hasLoadedRef.current) {
        hasLoadedRef.current = true

        return
      }

      const lastPost = posts[posts.length - 1]

      setHighlightedPost(lastPost)

      if (lastPost.authorId !== session.userId) {
        setHasNewMessages(true)
      }
    },
    [session.userId]
  )

  const handlePostHighlight = useCallback(
    (post) => {
      highlightedPostRef.current = post

      if (!highlightedPost) {
        return
      }

      if (highlightedPost.authorId === session.userId) {
        post.scrollIntoView()
      }
    },
    [highlightedPost, session.userId]
  )

  const handleAfterPostHighlight = useCallback(() => {
    setHasNewMessages(false)
  }, [])

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
        cacheKey: `posts-${session.discussion.id}`,
        hasNewMessages: hasNewMessages,
        highlightedPost: highlightedPost,
        handleAfterPostHighlight: handleAfterPostHighlight,
        handlePostsChange: handlePostsChange,
        handlePostHighlight: handlePostHighlight,
        handleFinish: handleFinish,
        highlightedPostRef: highlightedPostRef,
        previouslyNotFinishedRef: previouslyNotFinishedRef,
        finishedWizardRef: finishedWizardRef,
      }}
    >
      {children}
    </DiscussionContext.Provider>
  )
}
