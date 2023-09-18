import React, { useState } from 'react'
import { useMachine } from '@xstate/react'
import { createMachine } from 'xstate'
import { redirectTo } from '@/utils/redirect-to'
import { MentorDiscussion, DiscussionLinks } from '@/components/types'
import { Modal, ModalProps } from '../Modal'
import * as Step from './finish-mentor-discussion-modal'

export type ReportReason = 'coc' | 'incorrect' | 'other'

export type MentorReport = {
  requeue: boolean
  report: boolean
  reason: ReportReason
}

const modalStepMachine = createMachine({
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
  links: DiscussionLinks
}): JSX.Element => {
  const [currentStep, send] = useMachine(modalStepMachine)
  const [report, setReport] = useState<MentorReport | null>(null)

  switch (currentStep.value) {
    case 'rateMentor':
      return (
        <Step.RateMentorStep
          discussion={discussion}
          onHappy={() => send('HAPPY')}
          onSatisfied={() => send('SATISFIED')}
          onUnhappy={() => send('UNHAPPY')}
        />
      )
    case 'addTestimonial':
      return (
        <Step.AddTestimonialStep
          onSubmit={() => send('SUBMIT')}
          onSkip={() => redirectTo(links.exercise)}
          onBack={() => send('BACK')}
          discussion={discussion}
        />
      )
    case 'celebration':
      if (links.donationLinks.showDonationModal) {
        return (
          <Step.DonationStep
            exerciseLink={links.exercise}
            donationLinks={links.donationLinks}
            mentorHandle={discussion.mentor.handle}
          />
        )
      } else
        return (
          <Step.CelebrationStep
            mentorHandle={discussion.mentor.handle}
            links={links}
          />
        )
    case 'satisfied':
      return (
        <Step.SatisfiedStep
          discussion={discussion}
          onRequeued={() => send('REQUEUED')}
          onBack={() => send('BACK')}
          onNotRequeued={() => {
            redirectTo(links.exercise)
          }}
        />
      )
    case 'requeued':
      return <Step.RequeuedStep links={links} />
    case 'report':
      return (
        <Step.ReportStep
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

      return <Step.UnhappyStep report={report} links={links} />
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
  links: DiscussionLinks
  discussion: MentorDiscussion
  onCancel: () => void
}): JSX.Element => {
  return (
    <Modal
      style={{ content: { maxWidth: '100%' } }}
      cover
      aria={{ modal: true, describedby: 'a11y-finish-mentor-discussion' }}
      className="m-finish-student-mentor-discussion"
      ReactModalClassName="bg-unnamed15"
      {...props}
    >
      <Inner links={links} discussion={discussion} />
    </Modal>
  )
}
