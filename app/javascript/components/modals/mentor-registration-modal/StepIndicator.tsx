import React from 'react'
import { StepProps, ModalStep } from '../MentorRegistrationModal'

const Step = ({
  num,
  label,
  selected,
}: {
  num: number
  label: string
  selected: boolean
}) => {
  const srText = `Step ${num}: ${label}`

  const classNames = ['step', selected ? 'selected' : '']

  return (
    <li
      className={classNames.join(' ')}
      aria-current={selected ? 'step' : undefined}
    >
      <span className="sr-only">{srText}</span>
    </li>
  )
}

export const StepIndicator = ({
  steps,
  currentStep,
}: {
  steps: StepProps[]
  currentStep: ModalStep
}): JSX.Element => {
  return (
    <ul aria-label="Become a mentor progress" className="steps">
      {steps.map((step, i) => {
        return (
          <Step
            label={step.label}
            key={step.id}
            num={i + 1}
            selected={step.id === currentStep}
          />
        )
      })}
    </ul>
  )
}
