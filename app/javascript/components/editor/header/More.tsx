import React, { useCallback, useState } from 'react'
import { GraphicalIcon, Icon } from '../../common'
import { BugReportModal } from '../../modals/BugReportModal'
import { useDropdown } from '../../dropdowns/useDropdown'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const More = ({
  onRevertToLastIteration,
  onRevertToExerciseStart,
  trackSlug,
  exerciseSlug,
}: {
  onRevertToLastIteration: () => void
  onRevertToExerciseStart: () => void
  trackSlug: string
  exerciseSlug: string
}): JSX.Element => {
  const { t } = useAppTranslation('components/editor/header')
  const [isModalOpen, setIsModalOpen] = useState(false)
  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
    open,
    setOpen,
  } = useDropdown(3, undefined, {
    placement: 'bottom-end',
    modifiers: [
      {
        name: 'offset',
        options: {
          offset: [-8, 8],
        },
      },
    ],
  })

  const handleRevertToLastIteration = useCallback(() => {
    onRevertToLastIteration()

    setOpen(false)
  }, [onRevertToLastIteration, setOpen])

  const handleRevertToExerciseStart = useCallback(() => {
    onRevertToExerciseStart()

    setOpen(false)
  }, [onRevertToExerciseStart, setOpen])
  const handleOpenReport = useCallback(() => {
    setIsModalOpen(true)

    setOpen(false)
  }, [setOpen, setIsModalOpen])

  return (
    <React.Fragment>
      <BugReportModal
        open={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        trackSlug={trackSlug}
        exerciseSlug={exerciseSlug}
      />
      <button {...buttonAttributes} className="more-btn">
        <Icon icon="more-horizontal" alt={t('more.openMoreOptions')} />
      </button>
      {open ? (
        <div
          {...panelAttributes}
          className="actions-dialog c-dropdown-generic-menu"
        >
          <ul {...listAttributes}>
            <li {...itemAttributes(0)}>
              <button type="button" onClick={handleRevertToExerciseStart}>
                <GraphicalIcon icon="reset" />
                {t('more.revertToExerciseStart')}
              </button>
            </li>
            <li {...itemAttributes(1)}>
              <button onClick={handleRevertToLastIteration} type="button">
                <GraphicalIcon icon="reset" />
                {t('more.revertToLastIteration')}
              </button>
            </li>
            <li {...itemAttributes(2)}>
              <button type="button" onClick={handleOpenReport}>
                <GraphicalIcon icon="bug" />
                {t('more.reportABug')}
              </button>
            </li>
          </ul>
        </div>
      ) : null}
    </React.Fragment>
  )
}
