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

export type Size = 'm' | 'l'

export default function TryMentoringButton({
  links,
  text,
  size,
}: {
  links: Links
  text: string
  size: Size
}): JSX.Element {
  const [open, setOpen] = useState(false)

  return (
    <div>
      <button
        type="button"
        className={`btn-primary btn-${size}`}
        onClick={() => setOpen(true)}
      >
        {text}
      </button>
      <MentorRegistrationModal
        open={open}
        links={links}
        onClose={() => setOpen(false)}
      />
    </div>
  )
}
