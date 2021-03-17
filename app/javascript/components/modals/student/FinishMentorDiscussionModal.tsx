import React from 'react'
import { RateMentorStep } from './finish-mentor-discussion-modal/RateMentorStep'
import { AddTestimonialStep } from './finish-mentor-discussion-modal/AddTestimonialStep'
import { CelebrationStep } from './finish-mentor-discussion-modal/CelebrationStep'
import { UnhappyStep } from './finish-mentor-discussion-modal/UnhappyStep'
import { RequeuedStep } from './finish-mentor-discussion-modal/RequeuedStep'
import { SatisfiedStep } from './finish-mentor-discussion-modal/SatisfiedStep'
import { ReportStep } from './finish-mentor-discussion-modal/ReportStep'
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
      on: {
        HAPPY: 'addTestimonial',
        SATISFIED: 'satisfied',
        UNHAPPY: 'report',
      },
    },
    satisfied: {
      on: { REQUEUED: 'requeued' },
    },
    addTestimonial: {
      on: { SUBMIT: 'celebration' },
    },
    celebration: {},
    requeued: {},
    report: {
      on: { SUBMIT: 'unhappy' },
    },
    unhappy: {},
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
      return (
        <RateMentorStep
          onHappy={() => send('HAPPY')}
          onSatisfied={() => send('SATISFIED')}
          onUnhappy={() => send('UNHAPPY')}
        />
      )
    case 'addTestimonial':
      return (
        <AddTestimonialStep onSubmit={() => send('SUBMIT')} links={links} />
      )
    case 'celebration':
      return <CelebrationStep links={links} />
    case 'satisfied':
      return (
        <SatisfiedStep
          links={links}
          onRequeued={() => send('REQUEUED')}
          onNotRequeued={() => {
            window.location.replace(links.exercise)
          }}
        />
      )
    case 'requeued':
      return <RequeuedStep links={links} />
    case 'report':
      return <ReportStep links={links} onSubmit={() => send('SUBMIT')} />
    case 'unhappy':
      return <UnhappyStep links={links} />
  }
}
