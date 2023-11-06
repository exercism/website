import React, { useEffect, useState } from 'react'
import { useMachine } from '@xstate/react'
import { createMachine } from 'xstate'
import { redirectTo } from '@/utils/redirect-to'
import { MentorDiscussion, MentoringSessionDonation } from '@/components/types'
import { Modal, ModalProps } from '../Modal'
import * as Step from './finish-mentor-discussion-modal'
import { DiscussionActionsLinks } from '@/components/student/mentoring-session/DiscussionActions'
import currency from 'currency.js'

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
    celebration: {
      on: { SUCCESSFUL_DONATION: 'successfulDonation' },
    },
    requeued: {},
    report: {
      on: { SUBMIT: 'unhappy', BACK: 'rateMentor' },
    },
    unhappy: {},
    successfulDonation: {},
  },
})

const Inner = ({
  discussion,
  links,
  donation,
}: {
  discussion: MentorDiscussion
  links: DiscussionActionsLinks
  donation: MentoringSessionDonation
}): JSX.Element => {
  const [currentStep, send] = useMachine(modalStepMachine)
  const [report, setReport] = useState<MentorReport | null>(null)
  const [donatedAmount, setDonatedAmount] = useState<currency>(currency(0))

  // React 18 renders components async, we need to wait for report to arrive,
  // otherwise it will start rendering `unhappy` step before report arrives from mutation in ReportStep.tsx
  useEffect(() => {
    if (report) send('SUBMIT')
  }, [report])

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
      if (donation.showDonationModal) {
        return (
          <Step.DonationStep
            donation={donation}
            links={links}
            onSuccessfulDonation={(_, amount) => {
              setDonatedAmount(amount)
              send('SUCCESSFUL_DONATION')
            }}
          />
        )
      }
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
          send={send}
          onSubmit={setReport}
          onBack={() => send('BACK')}
        />
      )
    case 'successfulDonation':
      return (
        <Step.SuccessfulDonationStep
          amount={donatedAmount}
          closeLink={links.exerciseMentorDiscussionUrl}
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
  donation,
  ...props
}: Omit<ModalProps, 'className'> & {
  links: DiscussionActionsLinks
  discussion: MentorDiscussion
  donation: MentoringSessionDonation
  onCancel: () => void
}): JSX.Element => {
  return (
    <Modal
      style={{ content: { maxWidth: 'fit-content' } }}
      cover
      aria={{ modal: true, describedby: 'a11y-finish-mentor-discussion' }}
      className="m-finish-student-mentor-discussion"
      ReactModalClassName="bg-unnamed15"
      shouldCloseOnOverlayClick={false}
      {...props}
    >
      <Inner links={links} discussion={discussion} donation={donation} />
    </Modal>
  )
}
