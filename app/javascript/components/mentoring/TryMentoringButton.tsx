import React, { useState } from 'react'
import { MentorRegistrationModal } from '../modals/MentorRegistrationModal'

export type Links = {
  tracks: string
}

export const TryMentoringButton = ({
  links,
}: {
  links: Links
}): JSX.Element => {
  const [open, setOpen] = useState(false)

  return (
    <div>
      <button type="button" className="btn-cta" onClick={() => setOpen(true)}>
        Try mentoring now
      </button>
      <MentorRegistrationModal
        open={open}
        links={links}
        onClose={() => setOpen(false)}
      />
    </div>
  )
}
