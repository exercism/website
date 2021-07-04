import React, { useState } from 'react'
import { MentorRegistrationModal } from '../modals/MentorRegistrationModal'
import { Links as ChooseTrackStepLinks } from '../modals/mentor-registration-modal/ChooseTrackStep'
import { Links as CommitStepLinks } from '../modals/mentor-registration-modal/CommitStep'
import { Links as CongratulationsStepLinks } from '../modals/mentor-registration-modal/CongratulationsStep'

export type Links = {
  chooseTrackStep: ChooseTrackStepLinks
  commitStep: CommitStepLinks
  congratulationsStep: CongratulationsStepLinks
}

export const TryMentoringButton = ({
  links,
}: {
  links: Links
}): JSX.Element => {
  const [open, setOpen] = useState(false)

  return (
    <div>
      <button
        type="button"
        className="btn-primary btn-m"
        onClick={() => setOpen(true)}
      >
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
