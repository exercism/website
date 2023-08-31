import { useRequestQuery } from '../../../hooks/request-query'
import { DiscussionPostProps } from './DiscussionPost'
import { MentorDiscussion, Iteration } from '../../types'
import { QueryStatus } from '@tanstack/react-query'

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
  const { data, status } = useRequestQuery<{ items: DiscussionPostProps[] }>(
    [`posts-discussion-${discussion?.uuid}`],
    { endpoint: discussion?.links.posts, options: { enabled: !!discussion } }
  )

  return {
    iterations: data
      ? matchIterationsToPosts({ iterations: iterations, posts: data.items })
      : iterations,
    status: status,
  }
}
