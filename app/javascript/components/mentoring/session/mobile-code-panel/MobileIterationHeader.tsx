import React, { useCallback, useState } from 'react'
import { default as IterationSummaryWithWebsockets } from '@/components/track/IterationSummary'
import { CloseButton } from '../CloseButton'
import { OutOfDateNotice } from '@/components/track/iteration-summary/OutOfDateNotice'
import { CopyButton } from '../iteration-view/iteration-header/CopyButton'
import { SessionInfoModalProps, SessionInfoModal } from './SessionInfoModal'
import { SessionInfoHamburgerButton } from './SessionInfoHamburgerButton'
import type { Iteration, File } from '@/components/types'

export type MobileIterationHeaderProps = {
  iteration: Iteration
  isOutOfDate: boolean
  files: readonly File[] | undefined
} & Omit<SessionInfoModalProps, 'open' | 'onClose'>

export const MobileIterationHeader = ({
  iteration,
  isOutOfDate,
  files,
  links,
  discussion,
  exercise,
  session,
  setSession,
  student,
  track,
}: MobileIterationHeaderProps): JSX.Element => {
  const [modalOpen, setModalOpen] = useState(false)

  const handleModalOpen = useCallback(() => {
    setModalOpen(true)
  }, [])
  const handleModalClose = useCallback(() => {
    setModalOpen(false)
  }, [])
  return (
    <>
      <header className="iteration-header mobile">
        <CloseButton url={links.mentorDashboard} />
        <IterationSummaryWithWebsockets
          iteration={iteration}
          showSubmissionMethod={false}
          OutOfDateNotice={isOutOfDate ? <OutOfDateNotice /> : null}
          showTestsStatusAsButton={true}
          showFeedbackIndicator={false}
        />
        {files ? <CopyButton files={files} /> : null}
        <SessionInfoHamburgerButton onClick={handleModalOpen} />
      </header>
      <SessionInfoModal
        open={modalOpen}
        onClose={handleModalClose}
        discussion={discussion}
        exercise={exercise}
        links={links}
        session={session}
        setSession={setSession}
        student={student}
        track={track}
      />
    </>
  )
}
