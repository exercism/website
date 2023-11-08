import React, { useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { Loading } from '@/components/common'
import { ErrorBoundary, useErrorHandler } from '@/components/ErrorBoundary'
import { Modal } from '@/components/modals'
import { GenericTooltip } from '../../misc/ExercismTippy'

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
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation(async () => {
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
        <GenericTooltip
          content={
            "This button allows you to remove this discussion from your Inbox and return it to the student's Inbox. Use it when it's the student's turn but the system incorrectly thinks its yours."
          }
        >
          <div>
            <button
              onClick={() => setIsModalOpen(true)}
              type="button"
              className="btn-xs btn-enhanced"
            >
              <div className="--hint">It&apos;s the student&apos;s turn…</div>
            </button>
            <ConfirmationModal
              isOpen={isModalOpen}
              onClose={() => setIsModalOpen(false)}
              onConfirm={mutation}
            />
          </div>
        </GenericTooltip>
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
      <h2 className="text-h4 mb-8">
        Pass this discussion back to the student?
      </h2>
      <p className="text-p-base max-w-[540px] mb-8">
        Continuing will remove this from your Inbox and return it to the
        student&apos;s Inbox. This feature is intended for when a student has
        left a message for you such as &quot;Sure, I&apos;ll do that&quot; and
        the system now needs to be told it&apos;s still the student&apos;s turn
        to act.
      </p>
      <p className="text-p-base max-w-[540px] font-medium color-textColor2">
        If it may not be clear to the student that it&apos;s their turn to act,
        please add a comment to the discussion in addition to using this button.
      </p>
      <div className="flex gap-8 mt-20 ">
        <button className="btn-s btn-primary" onClick={onConfirm}>
          Continue
        </button>
        <button className="btn-s btn-default" onClick={onClose}>
          Cancel
        </button>
      </div>
    </Modal>
  )
}
