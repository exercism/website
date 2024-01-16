import React, { useCallback } from 'react'
import { QueryKey, useQueryClient, useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { Modal, ModalProps } from '@/components/modals/Modal'
import { Testimonial } from '@/components/types'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { PaginatedResult } from '../../TestimonialsList'

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
  const queryClient = useQueryClient()
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation(
    async () => {
      const { fetch } = sendRequest({
        endpoint: testimonial.links.delete,
        method: 'DELETE',
        body: null,
      })

      return fetch
    },
    {
      onSuccess: () => {
        queryClient.setQueryData<PaginatedResult | undefined>(
          cacheKey,
          (result) => {
            if (!result) {
              return
            }

            return {
              ...result,
              results: result.results.filter(
                (t) => t.uuid !== testimonial.uuid
              ),
            }
          }
        )
      },
    }
  )

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation()
    },
    [mutation]
  )

  const handleClose = useCallback(() => {
    if (status === 'loading') {
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
      <h3>Are you sure you want to delete this testimonial?</h3>
      <p>
        Deleting the testimonial will hide it from this list, your profile and
        mentoring stats. <strong>This action is irreversible.</strong>
      </p>
      <form data-turbo="false" onSubmit={handleSubmit} className="buttons">
        <FormButton type="submit" status={status} className="btn-warning btn-s">
          Delete testimonial
        </FormButton>
        <FormButton
          type="button"
          status={status}
          onClick={handleClose}
          className="btn-enhanced btn-s"
        >
          Cancel
        </FormButton>
      </form>
      <ErrorBoundary resetKeys={[status]}>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </Modal>
  )
}
