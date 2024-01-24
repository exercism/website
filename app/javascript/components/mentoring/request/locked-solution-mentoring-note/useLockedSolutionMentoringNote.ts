import { MentorSessionRequest } from '@/components/types'
import { sendRequest } from '@/utils/send-request'
import dayjs from 'dayjs'
import {
  useState,
  useEffect,
  Dispatch,
  SetStateAction,
  useCallback,
} from 'react'
import { useMutation } from '@tanstack/react-query'
type APIResponse = {
  mentorRequestLock: {
    lockedUntil: string
  }
}

type useLockedSolutionMentoringNoteReturns = {
  extendLockedUntil: () => void
  adjustOpenModalAt: () => void
  diff: number
  diffMins: string
  diffMinutes: string
  lockedUntil: string
  extendModalOpen: boolean
  setExtendModalOpen: Dispatch<SetStateAction<boolean>>
}

const shouldOpenExtendModal = (diff: number, openAt: number) =>
  diff <= openAt && diff > 0 && openAt !== 0

export function useLockedSolutionMentoringNote(
  request: MentorSessionRequest
): useLockedSolutionMentoringNoteReturns {
  const [lockedUntil, setLockedUntil] = useState(dayjs(request.lockedUntil))
  const [diff, setDiff] = useState(lockedUntil.diff(dayjs(), 'minute'))

  const [shouldOpenModalAt, setShouldOpenModalAt] = useState(10)
  const [extendModalOpen, setExtendModalOpen] = useState(
    shouldOpenExtendModal(diff, shouldOpenModalAt)
  )

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
      if (shouldOpenExtendModal(diffInMinute, shouldOpenModalAt)) {
        setExtendModalOpen(true)
      } else setExtendModalOpen(false)
    }, 60000)

    return () => clearInterval(interval)
  }, [lockedUntil, shouldOpenModalAt])

  const adjustOpenModalAt = useCallback(() => {
    if (diff > 10) {
      setShouldOpenModalAt(10)
    } else if (diff > 3) {
      setShouldOpenModalAt(3)
    } else if (diff > 1) {
      setShouldOpenModalAt(1)
    } else {
      setShouldOpenModalAt(0)
    }
  }, [diff])

  return {
    extendLockedUntil,
    diff,
    diffMins: `${diff} ${diff === 1 ? 'min' : 'mins'}`,
    diffMinutes: `${diff} ${diff === 1 ? 'minute' : 'minutes'}`,
    lockedUntil: lockedUntil.format('HH:mm'),
    extendModalOpen,
    setExtendModalOpen,
    adjustOpenModalAt,
  }
}
