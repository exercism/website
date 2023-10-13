import React, { useCallback, useContext, useState } from 'react'
import { default as IterationSummaryWithWebsockets } from '@/components/track/IterationSummary'
import type { Iteration, File } from '@/components/types'
import { CloseButton } from '../CloseButton'
import { OutOfDateNotice } from '@/components/track/iteration-summary/OutOfDateNotice'
import { CopyButton } from '../iteration-view/iteration-header/CopyButton'
import { SessionProps } from '../../Session'
import { Modal } from '@/components/modals'
import { DiscussionActions } from '../../discussion/DiscussionActions'
import { Avatar, Icon, TrackIcon } from '@/components/common'

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
        <SessionActionButton onClick={handleModalOpen} />
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

type SessionInfoModalProps = {
  open: boolean
  onClose: () => void
  session: SessionProps
  setSession: (session: SessionProps) => void
} & Pick<
  SessionProps,
  'discussion' | 'links' | 'student' | 'exercise' | 'track'
>
function SessionInfoModal({
  open,
  onClose,
  student,
  track,
  exercise,
  discussion,
  session,
  setSession,
}: SessionInfoModalProps) {
  return (
    <Modal open={open} onClose={onClose} className="m-session-info">
      <div className="session-info-header">
        <TrackIcon title={track.title} iconUrl={track.iconUrl} />
        <div className="student">
          <Avatar src={student.avatarUrl} handle={student.handle} />
          <div className="info">
            <div className="handle">{student.handle}</div>
            <div className="exercise">
              on {exercise.title} in {track.title}{' '}
            </div>
          </div>
        </div>
      </div>
      {discussion ? (
        <div className="flex flex-col gap-8 items-center">
          <DiscussionActions
            {...discussion}
            session={session}
            setSession={setSession}
          />
        </div>
      ) : null}
    </Modal>
  )
}

export function SessionActionButton({
  onClick,
}: {
  onClick: () => void
}): JSX.Element {
  return (
    <button
      className="btn-s btn-default download-btn"
      type="button"
      onClick={onClick}
    >
      <Icon icon="hamburger" alt="Download solution" />
    </button>
  )
}
