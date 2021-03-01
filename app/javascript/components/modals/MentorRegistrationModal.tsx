import React, { useState, useCallback } from 'react'
import { Modal, ModalProps } from './Modal'
import { StepIndicator } from './mentor-registration-modal/StepIndicator'
import { CloseButton } from './mentor-registration-modal/CloseButton'
import { ChooseTrackStep } from './mentor-registration-modal/ChooseTrackStep'
import { CommitStep } from './mentor-registration-modal/CommitStep'
import { CongratulationsStep } from './mentor-registration-modal/CongratulationsStep'
import { Links } from '../mentoring/TryMentoringButton'

export type ModalStep = 'CHOOSE_TRACK' | 'COMMIT' | 'CONGRATULATIONS'

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
  {
    id: 'CONGRATULATIONS',
    label: 'Congratulations',
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
  onBack,
}: {
  currentStep: ModalStep
  links: Links
  onContinue: () => void
  onBack: () => void
}): JSX.Element => {
  const [selected, setSelected] = useState<string[]>([])

  switch (currentStep) {
    case 'CHOOSE_TRACK':
      return (
        <ChooseTrackStep
          links={links.chooseTrackStep}
          selected={selected}
          setSelected={setSelected}
          onContinue={onContinue}
        />
      )
    case 'COMMIT':
      return (
        <CommitStep
          links={links.commitStep}
          selected={selected}
          onContinue={onContinue}
          onBack={onBack}
        />
      )
    case 'CONGRATULATIONS':
      return <CongratulationsStep links={links.congratulationsStep} />
  }
}

export const MentorRegistrationModal = ({
  onClose,
  links,
  ...props
}: Omit<ModalProps, 'className'> & { links: Links }): JSX.Element => {
  const [currentStep, setCurrentStep] = useState<ModalStep>('CHOOSE_TRACK')

  const moveForward = useCallback(() => {
    const nextStep = STEPS.findIndex((step) => step.id === currentStep) + 1

    setCurrentStep(STEPS[nextStep].id)
  }, [currentStep])

  const moveBack = useCallback(() => {
    const prevStep = STEPS.findIndex((step) => step.id === currentStep) - 1

    setCurrentStep(STEPS[prevStep].id)
  }, [currentStep])

  return (
    <Modal
      {...props}
      onClose={onClose}
      className="m-become-mentor"
      cover={true}
    >
      <div className="md-container">
        <ModalHeader>
          <StepIndicator steps={STEPS} currentStep={currentStep} />
          <CloseButton onClick={onClose} />
        </ModalHeader>
        <ModalBody
          currentStep={currentStep}
          links={links}
          onContinue={moveForward}
          onBack={moveBack}
        />
      </div>
    </Modal>
  )
}
