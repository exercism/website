import React from 'react'
import { Modal, ModalProps } from './Modal'
import { StepIndicator } from './mentor-registration-modal/StepIndicator'
import { CloseButton } from './mentor-registration-modal/CloseButton'
import { ChooseTrackStep } from './mentor-registration-modal/ChooseTrackStep'
import { Links } from '../mentoring/TryMentoringButton'

type ModalStep = 'CHOOSE_TRACK'

const ModalHeader = ({
  children,
}: {
  children?: React.ReactNode
}): JSX.Element => {
  return <header>{children}</header>
}

const ModalBody = ({
  currentStep,
  links,
}: {
  currentStep: ModalStep
  links: Links
}): JSX.Element => {
  switch (currentStep) {
    case 'CHOOSE_TRACK':
      return <ChooseTrackStep endpoint={links.tracks} />
  }
}

export const MentorRegistrationModal = ({
  onClose,
  links,
  ...props
}: Omit<ModalProps, 'className'> & { links: Links }): JSX.Element => {
  const currentStep: ModalStep = 'CHOOSE_TRACK'
  return (
    <Modal
      {...props}
      onClose={onClose}
      className="m-become-mentor"
      cover={true}
    >
      <ModalHeader>
        <StepIndicator />
        <CloseButton onClick={onClose} />
      </ModalHeader>
      <ModalBody currentStep={currentStep} links={links} />
    </Modal>
  )
}
