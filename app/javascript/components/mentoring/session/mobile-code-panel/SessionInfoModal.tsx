import React from 'react'
import { TrackIcon, Avatar } from '@/components/common'
import { Modal } from '@/components/modals'
import { SessionProps } from '../../Session'
import { DiscussionActions } from '../../discussion/DiscussionActions'

export type SessionInfoModalProps = {
  open: boolean
  onClose: () => void
  session: SessionProps
  setSession: (session: SessionProps) => void
} & Pick<
  SessionProps,
  'discussion' | 'links' | 'student' | 'exercise' | 'track'
>
export function SessionInfoModal({
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
