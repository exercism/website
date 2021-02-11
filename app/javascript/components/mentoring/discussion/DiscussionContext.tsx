import React, {
  useState,
  useCallback,
  createContext,
  useEffect,
  useRef,
} from 'react'
import { Discussion, SolutionProps } from '../Solution'
import { DiscussionPostProps } from './DiscussionPost'

type DiscussionContextType = {
  posts: string
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
  posts: '',
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
  solution,
  setSolution,
  children,
}: React.PropsWithChildren<{
  solution: SolutionProps
  setSolution: (solution: SolutionProps) => void
}>): JSX.Element => {
  const [hasNewMessages, setHasNewMessages] = useState(false)
  const [
    highlightedPost,
    setHighlightedPost,
  ] = useState<DiscussionPostProps | null>(null)
  const highlightedPostRef = useRef<HTMLDivElement | null>(null)
  const hasLoadedRef = useRef(false)

  const previouslyNotFinishedRef = useRef(!solution.discussion.isFinished)
  const finishedWizardRef = useRef<HTMLDivElement>(null)

  const handlePostsChange = useCallback(
    (posts) => {
      if (!hasLoadedRef.current) {
        hasLoadedRef.current = true

        return
      }

      const lastPost = posts[posts.length - 1]

      setHighlightedPost(lastPost)

      if (lastPost.authorId !== solution.userId) {
        setHasNewMessages(true)
      }
    },
    [solution.userId]
  )

  const handlePostHighlight = useCallback(
    (post) => {
      highlightedPostRef.current = post

      if (!highlightedPost) {
        return
      }

      if (highlightedPost.authorId === solution.userId) {
        post.scrollIntoView()
      }
    },
    [highlightedPost, solution.userId]
  )

  const handleAfterPostHighlight = useCallback(() => {
    setHasNewMessages(false)
  }, [])

  const handleFinish = useCallback(
    (discussion) => {
      setSolution({ ...solution, discussion: discussion })
    },
    [setSolution, solution]
  )

  useEffect(() => {
    if (!finishedWizardRef.current) {
      return
    }

    finishedWizardRef.current.scrollIntoView()
  }, [solution.relationship])

  return (
    <DiscussionContext.Provider
      value={{
        posts: `posts-${solution.discussion.id}`,
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
