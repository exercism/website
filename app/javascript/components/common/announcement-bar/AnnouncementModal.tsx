import React, { useCallback } from 'react'
import { useRequestQuery } from '../../../hooks/request-query'
import { FetchingBoundary } from '../../FetchingBoundary'
import { Modal, ModalProps } from '../../modals/Modal'

type APIResponse = {
  html: string
}

const DEFAULT_ERROR = new Error('Unable to load announcement')

export const AnnouncementModal = ({
  endpoint,
  onClose,
  ...props
}: Omit<ModalProps, 'className'> & { endpoint: string }): JSX.Element => {
  const { data, status, error } = useRequestQuery<APIResponse>('announcement', {
    endpoint: endpoint,
    options: {},
  })

  const handleClose = useCallback(() => {
    if (status === 'loading') {
      return
    }

    onClose()
  }, [onClose, status])

  return (
    <Modal onClose={handleClose} className="m-announcement" {...props}>
      <FetchingBoundary
        status={status}
        error={error}
        defaultError={DEFAULT_ERROR}
      >
        {data ? <div dangerouslySetInnerHTML={{ __html: data.html }} /> : null}
      </FetchingBoundary>
    </Modal>
  )
}
