import React, { useState } from 'react'
import { useMutation } from 'react-query'
import { sendRequest } from '@/utils'
import { Loading } from '@/components/common'
import { ErrorBoundary, useErrorHandler } from '@/components/ErrorBoundary'
import { Modal } from '@/components/modals'

type ComponentProps = {
  endpoint: string
}

export const MarkAsNothingToDoButton = (props: ComponentProps): JSX.Element => {
  return (
    <ErrorBoundary>
      <Component {...props} />
    </ErrorBoundary>
  )
}

const DEFAULT_ERROR = new Error('Unable to mark discussion as nothing to do')

const Component = ({ endpoint }: ComponentProps): JSX.Element | null => {
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [mutation, { status, error }] = useMutation(() => {
    const { fetch } = sendRequest({
      endpoint: endpoint,
      method: 'PATCH',
      body: null,
    })

    return fetch
  })

  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  switch (status) {
    case 'idle':
      return (
        <>
          <button
            onClick={() => setIsModalOpen(true)}
            type="button"
            className="btn-xs btn-enhanced"
          >
            <div className="--hint">Remove from Inbox</div>
          </button>
          <ConfirmationModal
            isOpen={isModalOpen}
            onClose={() => setIsModalOpen(false)}
            onConfirm={mutation}
          />
        </>
      )
    case 'loading':
      return <Loading />
    default:
      return null
  }
}

function ConfirmationModal({
  isOpen,
  onClose,
  onConfirm,
}: {
  isOpen: boolean
  onClose: () => void
  onConfirm: () => void
}) {
  return (
    <Modal open={isOpen} onClose={onClose}>
      Are you sure?
      <div className="flex gap-8 mt-32 ">
        <button className="btn-s btn-primary" onClick={onConfirm}>
          Yep
        </button>
        <button className="btn-s btn-default" onClick={onClose}>
          No
        </button>
      </div>
    </Modal>
  )
}
