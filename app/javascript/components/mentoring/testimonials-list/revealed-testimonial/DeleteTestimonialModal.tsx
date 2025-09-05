import React, { useCallback } from 'react'
import { QueryKey, useQueryClient, useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { Modal, ModalProps } from '@/components/modals/Modal'
import { Testimonial } from '@/components/types'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { PaginatedResult } from '../../TestimonialsList'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

const DEFAULT_ERROR = new Error('Unable to delete testimonial')

export const DeleteTestimonialModal = ({
  testimonial,
  cacheKey,
  onClose,
  ...props
}: Omit<ModalProps, 'className'> & {
  testimonial: Testimonial
  cacheKey: QueryKey
}): JSX.Element => {
  const { t } = useAppTranslation()
  const queryClient = useQueryClient()
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation({
    mutationFn: async () => {
      const { fetch } = sendRequest({
        endpoint: testimonial.links.delete,
        method: 'DELETE',
        body: null,
      })

      return fetch
    },
    onSuccess: () => {
      queryClient.setQueryData<PaginatedResult | undefined>(
        cacheKey,
        (result) => {
          if (!result) {
            return
          }

          return {
            ...result,
            results: result.results.filter((t) => t.uuid !== testimonial.uuid),
          }
        }
      )
    },
  })

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation()
    },
    [mutation]
  )

  const handleClose = useCallback(() => {
    if (status === 'pending') {
      return
    }

    onClose()
  }, [onClose, status])

  return (
    <Modal
      className="m-generic-confirmation"
      shouldCloseOnEsc={false}
      onClose={handleClose}
      {...props}
    >
      <h3>{t('deleteTestimonialModal.areYouSure')}</h3>
      <p>
        <Trans
          ns="components/mentoring/testimonials-list/revealed-testimonial"
          i18nKey="deleteTestimonialModal.deletingWillHide"
          components={{ strong: <strong /> }}
        />
      </p>
      <form data-turbo="false" onSubmit={handleSubmit} className="buttons">
        <FormButton type="submit" status={status} className="btn-warning btn-s">
          {t('deleteTestimonialModal.deleteTestimonial')}
        </FormButton>
        <FormButton
          type="button"
          status={status}
          onClick={handleClose}
          className="btn-enhanced btn-s"
        >
          {t('deleteTestimonialModal.cancel')}
        </FormButton>
      </form>
      <ErrorBoundary resetKeys={[status]}>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </Modal>
  )
}
