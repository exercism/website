import React, { useEffect, useState } from 'react'
import dayjs from 'dayjs'
import type { MentorSessionRequest } from '@/components/types'

type Links = {
  mentoringDocs: string
}

export const MentoringNote = ({
  links,
  request,
}: {
  links: Links
  request: MentorSessionRequest
}): JSX.Element => {
  const lockedAt = dayjs(request.lockedUntil)
  const [diff, setDiff] = useState(lockedAt.diff(dayjs(), 'minute'))

  useEffect(() => {
    const interval = setInterval(() => {
      setDiff(lockedAt.diff(dayjs(), 'minute'))
    }, 60000)

    return () => clearInterval(interval)
  }, [lockedAt])

  return (
    <div className="note">
      Check out our{' '}
      <a href={links.mentoringDocs} target="_blank" rel="noreferrer">
        mentoring docs
      </a>{' '}
      for more information. This solution is locked until{' '}
      {lockedAt.format('HH:mm')} ({diff} {diff === 1 ? 'minute' : 'minutes'})
    </div>
  )
}
