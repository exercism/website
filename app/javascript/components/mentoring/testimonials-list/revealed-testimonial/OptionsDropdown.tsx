import React, { useState, useCallback } from 'react'
import { QueryKey } from '@tanstack/react-query'
import { Icon } from '../../../common'
import { useDropdown } from '../../../dropdowns/useDropdown'
import { Testimonial } from '../../../types'
import { DeleteTestimonialModal } from './DeleteTestimonialModal'

export const OptionsDropdown = ({
  testimonial,
  cacheKey,
}: {
  testimonial: Testimonial
  cacheKey: QueryKey
}): JSX.Element => {
  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
    setOpen,
    open,
  } = useDropdown(1)
  const [isModalOpen, setIsModalOpen] = useState(false)

  const handleDelete = useCallback(() => {
    setOpen(false)
    setIsModalOpen(true)
  }, [setOpen])

  const handleModalClose = useCallback(() => {
    setIsModalOpen(false)
  }, [])

  return (
    <React.Fragment>
      <button className="options-button" {...buttonAttributes}>
        <Icon icon="more-horizontal" alt="Options" />
      </button>
      {open ? (
        <div {...panelAttributes} className="c-dropdown-generic-menu">
          <ul {...listAttributes}>
            <li {...itemAttributes(0)}>
              <button onClick={handleDelete}>Delete testimonial</button>
            </li>
          </ul>
        </div>
      ) : null}
      <DeleteTestimonialModal
        open={isModalOpen}
        onClose={handleModalClose}
        testimonial={testimonial}
        cacheKey={cacheKey}
      />
    </React.Fragment>
  )
}
