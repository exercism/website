import React from 'react'
import { RateMentorStep } from './finish-mentor-discussion-modal/RateMentorStep'
import { AddTestimonialStep } from './finish-mentor-discussion-modal/AddTestimonialStep'
import { CelebrationStep } from './finish-mentor-discussion-modal/CelebrationStep'
import { useMachine } from '@xstate/react'
import { Machine } from 'xstate'

export type Links = {
  exercise: string
  finish: string
}

const modalStepMachine = Machine({
  id: 'modalStep',
  initial: 'rateMentor',
  states: {
    rateMentor: {
      on: { HAPPY: 'addTestimonial' },
    },
    addTestimonial: {
      on: { SUBMIT: 'celebration' },
    },
    celebration: {},
  },
})

export const FinishMentorDiscussionModal = ({
  links,
}: {
  links: Links
}): JSX.Element => {
  const [currentStep, send] = useMachine(modalStepMachine)

  switch (currentStep.value) {
    case 'rateMentor':
      return <RateMentorStep onHappy={() => send('HAPPY')} />
    case 'addTestimonial':
      return (
        <AddTestimonialStep onSubmit={() => send('SUBMIT')} links={links} />
      )
    case 'celebration':
      return <CelebrationStep links={links} />
  }
}
