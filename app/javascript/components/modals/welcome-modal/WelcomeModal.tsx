import React, { useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { Modal, ModalProps } from '../Modal'
import { SeniorView } from './DeveloperView'

type WelcomeModalContextProps = {
  patchCloseModal: {
    mutate: () => void
  } & Pick<ReturnType<typeof useMutation>, 'status' | 'error'>
  numTracks: number
  open: boolean
  setOpen: React.Dispatch<React.SetStateAction<boolean>>
  links: {
    hideModalEndpoint: string
  }
}

export type SeniorityLevel =
  | 'absolute_beginner'
  | 'beginner'
  | 'junior'
  | 'mid'
  | 'senior'

export const WelcomeModalContext =
  React.createContext<WelcomeModalContextProps>({
    patchCloseModal: {
      mutate: () => null,
      status: 'idle',
      error: null,
    },
    numTracks: 0,
    open: false,
    setOpen: () => null,
    links: {
      hideModalEndpoint: '',
    },
  })

export default function WelcomeModal({
  links,
  numTracks,
  ...props
}: Omit<ModalProps, 'className' | 'open' | 'onClose'> & {
  links: {
    hideModalEndpoint: string
  }
  numTracks: number
}): JSX.Element {
  const [open, setOpen] = useState(true)

  const {
    mutate: hideModalMutation,
    status: hideModalMutationStatus,
    error: hideModalMutationError,
  } = useMutation({
    mutationFn: () => {
      const { fetch } = sendRequest({
        endpoint: links.hideModalEndpoint,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
    onSuccess: () => {
      setOpen(false)
    },
  })

  return (
    <WelcomeModalContext.Provider
      value={{
        patchCloseModal: {
          mutate: hideModalMutation,
          status: hideModalMutationStatus,
          error: hideModalMutationError,
        },
        open,
        setOpen,
        numTracks,
        links,
      }}
    >
      <Modal
        cover={true}
        open={open}
        style={{ content: { maxWidth: '1180px' } }}
        {...props}
        onClose={() => null}
        className="m-welcome"
      >
        <SeniorView />
      </Modal>
    </WelcomeModalContext.Provider>
  )
}
