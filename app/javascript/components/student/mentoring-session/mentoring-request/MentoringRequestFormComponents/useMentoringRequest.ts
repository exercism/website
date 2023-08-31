import { useCallback, useRef } from 'react'
import { MutationStatus, useMutation } from '@tanstack/react-query'
import { typecheck } from '@/utils'
import { sendRequest } from '@/utils/send-request'
import { MentorSessionRequest } from '@/components/types'

export function useMentoringRequest(
  links: { createMentorRequest: string },
  onSuccess: (mentorRequest: MentorSessionRequest) => void
): {
  handleSubmit: (e: React.FormEvent<HTMLFormElement>) => void
  trackObjectivesRef: React.RefObject<HTMLTextAreaElement>
  solutionCommentRef: React.RefObject<HTMLTextAreaElement>
  status: MutationStatus
  error: unknown
} {
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<MentorSessionRequest>(
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
