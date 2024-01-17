import React, { createContext, useCallback, useState } from 'react'
import { useMutation } from 'react-query'
import { sendRequest } from '@/utils/send-request'

// import { FormButton } from '../common'
// import { ErrorBoundary, ErrorMessage } from '../ErrorBoundary'
import { Track } from '@/components/types'
import { Modal, ModalProps } from '../Modal'
import { TrackWelcomeModalRHS as RHS } from './RHS'
import { TrackWelcomeModalLHS as LHS } from './LHS'
import {
  ChoicesType,
  StateEvent,
  UNSET_CHOICES,
  machine,
} from './LHS/lhs.machine'
import { useMachine } from '@xstate/react'
import { State, BaseActionObject, ResolveTypegenMeta, ServiceMap } from 'xstate'
import { Typegen0 } from './LHS/lhs.machine.typegen'

// const DEFAULT_ERROR = new Error('Unable to dismiss modal')

type CurrentState = State<
  {
    choices: {
      Mode: string
      Interface: string
    }
  },
  {
    type: StateEvent
  },
  any,
  {
    value: any
    context: {
      choices: {
        Mode: string
        Interface: string
      }
    }
  },
  ResolveTypegenMeta<
    Typegen0,
    {
      type: StateEvent
    },
    BaseActionObject,
    ServiceMap
  >
>

export const TrackContext = createContext<{
  track: Track
  choices: ChoicesType
  setChoices: React.Dispatch<React.SetStateAction<ChoicesType>>
  currentState: CurrentState
  send: any
}>({
  track: {} as Track,
  choices: UNSET_CHOICES,
  setChoices: () => {},
  currentState: {} as CurrentState,
  send: () => {},
})

export const TrackWelcomeModal = ({
  endpoint,
  track,
}: Omit<ModalProps, 'className' | 'open' | 'onClose'> & {
  endpoint: string
  track: Track
}): JSX.Element => {
  const [open, setOpen] = useState(true)
  const [choices, setChoices] = useState<ChoicesType>(UNSET_CHOICES)
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

  const [currentState, send] = useMachine(machine, {
    actions: {
      handleContinueToLocalMachine() {
        console.log('continue to cli hello world')
      },
      handleContinueToOnlineEditor() {
        console.log('continue to online hello world')
      },
    },
  })

  return (
    <Modal
      cover={true}
      open={open}
      onClose={() => null}
      className="m-track-welcome-modal"
    >
      <TrackContext.Provider
        value={{ track, choices, setChoices, currentState, send }}
      >
        <LHS />
        <RHS />
      </TrackContext.Provider>
    </Modal>
  )
}
