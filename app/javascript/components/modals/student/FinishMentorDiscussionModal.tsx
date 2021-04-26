import React from 'react'
import { MentorDiscussion } from '../../types'
import { Modal } from '../Modal'
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
      on: { REQUEUED: 'requeued', BACK: 'rateMentor' },
    },
    addTestimonial: {
      on: { SUBMIT: 'celebration', BACK: 'rateMentor' },
    },
    celebration: {},
    requeued: {},
    report: {
      on: { SUBMIT: 'unhappy', BACK: 'rateMentor' },
    },
    unhappy: {},
  },
})

const Inner = ({
  links,
  discussion,
}: {
  links: Links
  discussion: MentorDiscussion
}): JSX.Element => {
  const [currentStep, send] = useMachine(modalStepMachine)

  switch (currentStep.value) {
    case 'rateMentor':
      return (
        <RateMentorStep
          discussion={discussion}
          onHappy={() => send('HAPPY')}
          onSatisfied={() => send('SATISFIED')}
          onUnhappy={() => send('UNHAPPY')}
        />
      )
    case 'addTestimonial':
      return (
        <AddTestimonialStep
          onSubmit={() => send('SUBMIT')}
          onBack={() => send('BACK')}
          links={links}
          discussion={discussion}
        />
      )
    case 'celebration':
      return <CelebrationStep links={links} />
    case 'satisfied':
      return (
        <SatisfiedStep
          links={links}
          onRequeued={() => send('REQUEUED')}
          onBack={() => send('BACK')}
          onNotRequeued={() => {
            window.location.replace(links.exercise)
          }}
        />
      )
    case 'requeued':
      return <RequeuedStep links={links} />
    case 'report':
      return (
        <ReportStep
          discussion={discussion}
          links={links}
          onSubmit={() => send('SUBMIT')}
          onBack={() => send('BACK')}
        />
      )
    case 'unhappy':
      return <UnhappyStep links={links} />
    default:
      throw new Error('Unknown modal step')
  }
}

export const FinishMentorDiscussionModal = ({
  links,
  discussion,
}: {
  links: Links
  discussion: MentorDiscussion
}): JSX.Element => {
  return (
    <Modal
      open={true}
      cover={true}
      onClose={() => {}}
      ariaHideApp={false}
      className="m-finish-student-mentor-discussion"
    >
      <Inner links={links} discussion={discussion} />
    </Modal>
  )
}
