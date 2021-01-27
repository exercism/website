import React from 'react'
import { Modal as BaseModal } from '../modals/Modal'

export const Modal = ({ html }: { html: string }): JSX.Element => {
  return (
    <BaseModal open={true} onClose={() => {}} className="">
      <div dangerouslySetInnerHTML={{ __html: html }} />
    </BaseModal>
  )
}
