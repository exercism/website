import { useIsMounted } from 'use-is-mounted'
import { useRequestQuery } from '../../../hooks/request-query'
import { DiscussionPostProps } from './DiscussionPost'
import { MentorDiscussion, Iteration } from '../../types'
import { QueryStatus } from 'react-query'

const matchIterationsToPosts = ({
  iterations,
  posts,
}: {
  iterations: readonly Iteration[]
  posts: DiscussionPostProps[]
}): Iteration[] => {
  return iterations.reduce<Iteration[]>((iterationsWithPosts, iteration) => {
    const iterationPosts = posts
      ? posts.filter((post) => post.iterationIdx === iteration.idx)
      : []

    iterationsWithPosts.push({ ...iteration, posts: iterationPosts })

    return iterationsWithPosts
  }, [])
}

export const useDiscussionIterations = ({
  discussion,
  iterations,
}: {
  discussion?: MentorDiscussion
  iterations: readonly Iteration[]
}): { iterations: readonly Iteration[]; status: QueryStatus } => {
  const isMountedRef = useIsMounted()
  const { data, status } = useRequestQuery<{ posts: DiscussionPostProps[] }>(
    `posts-discussion-${discussion?.uuid}`,
    { endpoint: discussion?.links.posts, options: { enabled: !!discussion } },
    isMountedRef
  )

  return {
    iterations: data
      ? matchIterationsToPosts({ iterations: iterations, posts: data.posts })
      : iterations,
    status: status,
  }
}
