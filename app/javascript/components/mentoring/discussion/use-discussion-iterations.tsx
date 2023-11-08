import { useEffect, useState } from 'react'
import { useRequestQuery } from '../../../hooks/request-query'
import { DiscussionPostProps } from './DiscussionPost'
import { MentorDiscussion, Iteration } from '../../types'
import { QueryStatus } from '@tanstack/react-query'
import { SolutionWithLatestIterationChannel } from '@/channels/solutionWithLatestIterationChannel'

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
  studentSolutionUuid,
}: {
  discussion?: MentorDiscussion
  iterations: readonly Iteration[]
  studentSolutionUuid: string
}): {
  iterations: readonly Iteration[]
  status: QueryStatus
  setIterations: React.Dispatch<React.SetStateAction<Iteration[]>>
} => {
  const [iterationList, setIterationList] = useState<Iteration[]>(
    iterations as Iteration[]
  )
  const { data, status } = useRequestQuery<{ items: DiscussionPostProps[] }>(
    [`posts-discussion-${discussion?.uuid}`],
    { endpoint: discussion?.links.posts, options: { enabled: !!discussion } }
  )

  useEffect(() => {
    const solutionWithLatestIterationChannel =
      new SolutionWithLatestIterationChannel(
        { uuid: studentSolutionUuid },
        (response) => {
          setIterationList((existingIterations) => {
            if (
              existingIterations.some(
                (iteration) => iteration.idx === response.iteration.idx
              )
            )
              return existingIterations
            else
              return [
                ...existingIterations,
                { ...response.iteration, new: true },
              ]
          })
        }
      )

    return () => {
      solutionWithLatestIterationChannel.disconnect()
    }
  }, [])

  return {
    iterations: data
      ? matchIterationsToPosts({ iterations: iterationList, posts: data.items })
      : iterationList,
    status: status,
    setIterations: setIterationList,
  }
}
