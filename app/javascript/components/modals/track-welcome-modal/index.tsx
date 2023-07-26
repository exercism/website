import React, { createContext, useCallback, useState } from 'react'
import { useMutation } from 'react-query'
import { sendRequest } from '@/utils'

// import { FormButton } from '../common'
// import { ErrorBoundary, ErrorMessage } from '../ErrorBoundary'
import { Track } from '@/components/types'
import { Modal, ModalProps } from '../Modal'
import { TrackWelcomeModalLHS as LHS } from './LHS'
import { TrackWelcomeModalRHS as RHS } from './RHS'

// const DEFAULT_ERROR = new Error('Unable to dismiss modal')

export const TrackContext = createContext<Track>({} as Track)

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

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
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
      <TrackContext.Provider value={track}>
        <RHS />
      </TrackContext.Provider>
    </Modal>
  )
}
