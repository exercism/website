import React, { useCallback, useState } from 'react'
import { QueryStatus, useMutation } from 'react-query'
import { sendRequest } from '@/utils'
import { Modal, ModalProps } from './Modal'
// import { FormButton } from '../common'
// import { ErrorBoundary, ErrorMessage } from '../ErrorBoundary'
import { Track } from '../types'

// const DEFAULT_ERROR = new Error('Unable to dismiss modal')

export const TrackWelcomeModal = ({
  endpoint,
  track,
}: Omit<ModalProps, 'className' | 'open' | 'onClose'> & {
  endpoint: string
  track: Track
}): JSX.Element => {
  const [open, setOpen] = useState(true)
  const [mutation, { status, error }] = useMutation(
    () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
    {
      onSuccess: () => {
        handleClose()
      },
    }
  )

  const handleClick = useCallback(() => {
    mutation()
  }, [mutation])

  const handleClose = useCallback(() => {
    if (status === 'loading') {
      return
    }

    setOpen(false)
  }, [status])

  return (
    <Modal
      cover={true}
      open={open}
      onClose={() => null}
      className="m-track-welcome-modal"
    >
      <LHS />
      <RHS
        track={track}
        handleClick={handleClick}
        error={error}
        status={status}
      />
    </Modal>
  )
}

function RHS({
  // handleClick,
  // error,
  // status,
  track,
}: {
  handleClick: () => void
  error: unknown
  status: QueryStatus
  track: Track
}) {
  return (
    <div className="rhs">
      <header>
        <h1 className="text-h1">Welcome to {track.title}! 💙</h1>
        <p>
          This track can be used for learning {track.title} or for practicing
          your existing {track.title} knowledge. Our {track.title} syllabus
          teaches&nbsp;
          {track.numConcepts} different {track.title}&nbsp; Concepts, and we
          have {track.numExercises} exercises to practice on.
        </p>

        <p>Would you like to use the track in learning mode or practice mode</p>
      </header>

      <div className="flex gap-12 items-center">
        <button className="btn-primary btn-l">Learning Mode</button>
        <button className="btn-primary btn-l">Practice Mode</button>
      </div>
      {/* <FormButton
        status={status}
        className="btn-primary btn-l"
        type="button"
        onClick={handleClick}
      >
        Great. Let&apos;s go!
      </FormButton>
      <ErrorBoundary resetKeys={[status]}>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary> */}
    </div>
  )
}

function LHS() {
  return (
    <div className="lhs">
      <div
        className="video relative rounded-8 overflow-hidden !mb-24"
        style={{ padding: '56.25% 0 0 0', position: 'relative' }}
      >
        <iframe
          src="https://www.youtube-nocookie.com/embed/zomfphsDQrs"
          title="Welcome to Exercism Insiders!"
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          allowFullScreen
        />
      </div>
    </div>
  )
}
