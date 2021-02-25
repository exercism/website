import React, { useState, useCallback } from 'react'
import { Modal, ModalProps } from './Modal'
import { StepIndicator } from './mentor-registration-modal/StepIndicator'
import { CloseButton } from './mentor-registration-modal/CloseButton'
import { ChooseTrackStep } from './mentor-registration-modal/ChooseTrackStep'
import { CommitStep } from './mentor-registration-modal/CommitStep'
import { Links } from '../mentoring/TryMentoringButton'

export type ModalStep = 'CHOOSE_TRACK' | 'COMMIT'

export type StepProps = {
  id: ModalStep
  label: string
}

const STEPS: StepProps[] = [
  {
    id: 'CHOOSE_TRACK',
    label: 'Select the tracks you want to mentor',
  },
  {
    id: 'COMMIT',
    label: 'Commit to being a good mentor',
  },
]

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
  onContinue,
}: {
  currentStep: ModalStep
  links: Links
  onContinue: () => void
}): JSX.Element => {
  switch (currentStep) {
    case 'CHOOSE_TRACK':
      return (
        <ChooseTrackStep
          links={links.chooseTrackStep}
          onContinue={onContinue}
        />
      )
    case 'COMMIT':
      return <CommitStep links={links.commitStep} />
  }
}

export const MentorRegistrationModal = ({
  onClose,
  links,
  ...props
}: Omit<ModalProps, 'className'> & { links: Links }): JSX.Element => {
  const [currentStep, setCurrentStep] = useState<ModalStep>('CHOOSE_TRACK')

  const moveToNextStep = useCallback(() => {
    const nextStep = STEPS.findIndex((step) => step.id === currentStep) + 1

    setCurrentStep(STEPS[nextStep].id)
  }, [currentStep])
  return (
    <Modal
      {...props}
      onClose={onClose}
      className="m-become-mentor"
      cover={true}
    >
      <ModalHeader>
        <StepIndicator steps={STEPS} currentStep={currentStep} />
        <CloseButton onClick={onClose} />
      </ModalHeader>
      <ModalBody
        currentStep={currentStep}
        links={links}
        onContinue={moveToNextStep}
      />
    </Modal>
  )
}
