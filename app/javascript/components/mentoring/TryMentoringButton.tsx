import React, { useState } from 'react'
import { MentorRegistrationModal } from '../modals/MentorRegistrationModal'
import { Links as ChooseTrackStepLinks } from '../modals/mentor-registration-modal/ChooseTrackStep'
import { Links as CommitStepLinks } from '../modals/mentor-registration-modal/CommitStep'

export type Links = {
  chooseTrackStep: ChooseTrackStepLinks
  commitStep: CommitStepLinks
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
