import React from 'react'
import { Testimonial } from '../types'
import { Modal, ModalProps } from './Modal'

export const TestimonialModal = ({
  testimonial,
  ...props
}: Omit<ModalProps, 'className'> & {
  testimonial: Testimonial
}): JSX.Element => {
  return (
    <Modal className="m-testimonial-modal" {...props}>
      {testimonial.content}
    </Modal>
  )
}
