import { useCallback, useRef } from 'react'
import { QueryStatus, useMutation } from 'react-query'
import { sendRequest, typecheck } from '@/utils'
import { MentorSessionRequest } from '@/components/types'
import type { Links } from '.'

export function useMentoringRequest(
  links: Links,
  onSuccess: (mentorRequest: MentorSessionRequest) => void
): {
  handleSubmit: (e: React.FormEvent<HTMLFormElement>) => void
  trackObjectivesRef: React.RefObject<HTMLTextAreaElement>
  solutionCommentRef: React.RefObject<HTMLTextAreaElement>
  status: QueryStatus
  error: unknown
} {
  const [mutation, { status, error }] = useMutation<MentorSessionRequest>(
    async () => {
      const { fetch } = sendRequest({
        endpoint: links.createMentorRequest,
        method: 'POST',
        body: JSON.stringify({
          comment: solutionCommentRef.current?.value,
          track_objectives: trackObjectivesRef.current?.value,
        }),
      })

      return fetch.then((json) =>
        typecheck<MentorSessionRequest>(json, 'mentorRequest')
      )
    },
    {
      onSuccess,
    }
  )

  const handleSubmit = useCallback(
    (e: React.FormEvent<HTMLFormElement>) => {
      e.preventDefault()

      mutation()
    },
    [mutation]
  )

  const trackObjectivesRef = useRef<HTMLTextAreaElement>(null)
  const solutionCommentRef = useRef<HTMLTextAreaElement>(null)

  return { handleSubmit, trackObjectivesRef, solutionCommentRef, status, error }
}
