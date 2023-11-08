import { MentorSessionRequest } from '@/components/types'
import { sendRequest } from '@/utils/send-request'
import dayjs from 'dayjs'
import { useState, useEffect, Dispatch, SetStateAction } from 'react'
import { useMutation } from '@tanstack/react-query'
type APIResponse = {
  mentorRequestLock: {
    lockedUntil: string
  }
}

type useLockedSolutionMentoringNoteReturns = {
  extendLockedUntil: () => void
  diff: number
  diffMins: string
  diffMinutes: string
  lockedUntil: string
  extendModalOpen: boolean
  setExtendModalOpen: Dispatch<SetStateAction<boolean>>
}
export function useLockedSolutionMentoringNote(
  request: MentorSessionRequest
): useLockedSolutionMentoringNoteReturns {
  const [lockedUntil, setLockedUntil] = useState(dayjs(request.lockedUntil))
  const [diff, setDiff] = useState(lockedUntil.diff(dayjs(), 'minute'))
  const [extendModalOpen, setExtendModalOpen] = useState(diff <= 10 && diff > 0)

  const { mutate: extendLockedUntil } = useMutation<APIResponse>(
    () => {
      const { fetch } = sendRequest({
        endpoint: request.links.extendLock,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
    {
      onSuccess: (response) => {
        const lockedUntilResponse = dayjs(
          response.mentorRequestLock.lockedUntil
        )
        setLockedUntil(lockedUntilResponse)
        setDiff(lockedUntilResponse.diff(dayjs(), 'minute'))
        setExtendModalOpen(false)
      },
    }
  )

  useEffect(() => {
    const interval = setInterval(() => {
      const diffInMinute = lockedUntil.diff(dayjs(), 'minute')
      setDiff(diffInMinute)
      if (diffInMinute <= 10 && diffInMinute > 0) {
        setExtendModalOpen(true)
      } else setExtendModalOpen(false)
    }, 60000)

    return () => clearInterval(interval)
  }, [lockedUntil])

  return {
    extendLockedUntil,
    diff,
    diffMins: `${diff} ${diff === 1 ? 'min' : 'mins'}`,
    diffMinutes: `${diff} ${diff === 1 ? 'minute' : 'minutes'}`,
    lockedUntil: lockedUntil.format('HH:mm'),
    extendModalOpen,
    setExtendModalOpen,
  }
}
