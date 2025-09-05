import React, { useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { Loading } from '@/components/common'
import { ErrorBoundary, useErrorHandler } from '@/components/ErrorBoundary'
import { Modal } from '@/components/modals'
import { GenericTooltip } from '../../misc/ExercismTippy'
import { useAppTranslation } from '@/i18n/useAppTranslation'

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
  const { t } = useAppTranslation()
  const [isModalOpen, setIsModalOpen] = useState(false)
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation({
    mutationFn: async () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
  })

  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  switch (status) {
    case 'idle':
      return (
        <GenericTooltip content={t('markAsNothingToDoButton.studentsTurn')}>
          <div>
            <button
              onClick={() => setIsModalOpen(true)}
              type="button"
              className="btn-xs btn-enhanced"
            >
              <div className="--hint">
                {t('markAsNothingToDoButton.itsTheStudentsTurn')}
              </div>
            </button>
            <ConfirmationModal
              isOpen={isModalOpen}
              onClose={() => setIsModalOpen(false)}
              onConfirm={mutation}
            />
          </div>
        </GenericTooltip>
      )
    case 'pending':
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
  const { t } = useAppTranslation()

  return (
    <Modal open={isOpen} onClose={onClose}>
      <h2 className="text-h4 mb-8">
        {t('markAsNothingToDoButton.passDiscussionBack')}
      </h2>
      <p className="text-p-base max-w-[540px] mb-8">
        {t('markAsNothingToDoButton.continuingWillRemove')}
      </p>
      <p className="text-p-base max-w-[540px] font-medium color-textColor2">
        {t('markAsNothingToDoButton.addCommentToDiscussion')}
      </p>
      <div className="flex gap-8 mt-20 ">
        <button className="btn-s btn-primary" onClick={onConfirm}>
          {t('markAsNothingToDoButton.continue')}
        </button>
        <button className="btn-s btn-default" onClick={onClose}>
          {t('markAsNothingToDoButton.cancel')}
        </button>
      </div>
    </Modal>
  )
}
