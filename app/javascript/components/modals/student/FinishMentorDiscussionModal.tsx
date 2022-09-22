import React, { useState } from 'react'
import { MentorDiscussion } from '../../types'
import { Modal, ModalProps } from '../Modal'
import { RateMentorStep } from './finish-mentor-discussion-modal/RateMentorStep'
import { AddTestimonialStep } from './finish-mentor-discussion-modal/AddTestimonialStep'
import { CelebrationStep } from './finish-mentor-discussion-modal/CelebrationStep'
import { UnhappyStep } from './finish-mentor-discussion-modal/UnhappyStep'
import { RequeuedStep } from './finish-mentor-discussion-modal/RequeuedStep'
import { SatisfiedStep } from './finish-mentor-discussion-modal/SatisfiedStep'
import { ReportStep } from './finish-mentor-discussion-modal/ReportStep'
import { useMachine } from '@xstate/react'
import { Machine } from 'xstate'
import { redirectTo } from '../../../utils/redirect-to'
import { DonationStep } from './finish-mentor-discussion-modal/DonationStep'

export type Links = {
  exercise: string
}

export type ReportReason = 'coc' | 'incorrect' | 'other'

export type MentorReport = {
  requeue: boolean
  report: boolean
  reason: ReportReason
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
  discussion,
  links,
}: {
  discussion: MentorDiscussion
  links: Links
}): JSX.Element => {
  const [currentStep, send] = useMachine(modalStepMachine)
  const [report, setReport] = useState<MentorReport | null>(null)

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
          onSkip={() => redirectTo(links.exercise)}
          onBack={() => send('BACK')}
          discussion={discussion}
        />
      )
    case 'celebration':
      return (
        <DonationStep mentorHandle={discussion.mentor.handle} />
        // <CelebrationStep
        //   mentorHandle={discussion.mentor.handle}
        //   links={links}
        // />
      )
    case 'satisfied':
      return (
        <SatisfiedStep
          discussion={discussion}
          onRequeued={() => send('REQUEUED')}
          onBack={() => send('BACK')}
          onNotRequeued={() => {
            redirectTo(links.exercise)
          }}
        />
      )
    case 'requeued':
      return <RequeuedStep links={links} />
    case 'report':
      return (
        <ReportStep
          discussion={discussion}
          onSubmit={(report) => {
            setReport(report)
            send('SUBMIT')
          }}
          onBack={() => send('BACK')}
        />
      )
    case 'unhappy': {
      if (!report) {
        throw new Error('Report should not be null')
      }

      return <UnhappyStep report={report} links={links} />
    }
    default:
      throw new Error('Unknown modal step')
  }
}

export const FinishMentorDiscussionModal = ({
  links,
  discussion,
  ...props
}: Omit<ModalProps, 'className'> & {
  links: Links
  discussion: MentorDiscussion
  onCancel: () => void
}): JSX.Element => {
  return (
    <Modal
      style={{ content: { maxWidth: '100%' } }}
      cover
      aria={{ modal: true, describedby: 'a11y-finish-mentor-discussion' }}
      className="m-finish-student-mentor-discussion"
      ReactModalClassName="!bg-unnamed15"
      {...props}
    >
      <Inner links={links} discussion={discussion} />
    </Modal>
  )
}
