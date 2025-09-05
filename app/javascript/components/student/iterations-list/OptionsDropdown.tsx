// i18n-key-prefix: optionsDropdown
// i18n-namespace: components/student/iterations-list
import React, { useState, useCallback } from 'react'
import { Icon } from '../../common'
import { useDropdown } from '../../dropdowns/useDropdown'
import { Iteration } from '../../types'
import { DeleteIterationModal } from './DeleteIterationModal'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const OptionsDropdown = ({
  iteration,
  onDelete,
}: {
  iteration: Iteration
  onDelete: (iteration: Iteration) => void
}): JSX.Element => {
  const { t } = useAppTranslation()
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
        <Icon
          icon="more-horizontal"
          alt={t('optionsDropdown.optionsForIteration', {
            iterationIdx: iteration.idx,
          })}
        />
      </button>
      {open ? (
        <div {...panelAttributes} className="c-dropdown-generic-menu">
          <ul {...listAttributes}>
            <li {...itemAttributes(0)}>
              <button onClick={handleDelete}>
                {t('optionsDropdown.deleteIteration')}
              </button>
            </li>
          </ul>
        </div>
      ) : null}
      <DeleteIterationModal
        open={isModalOpen}
        onClose={handleModalClose}
        iteration={iteration}
        onSuccess={onDelete}
      />
    </React.Fragment>
  )
}
