import React, { useCallback, useState } from 'react'
import GraphicalIcon from '@/components/common/GraphicalIcon'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { ManageCustomFunctionsModal } from './ManageCustomFunctionsModal'

export function SettingsButton() {
  const [isDialogOpen, setIsDialogOpen] = useState(false)
  const [isManagerModalOpen, setIsManagerModalOpen] = useState(false)

  const toggleIsDialogOpen = useCallback(() => {
    setIsDialogOpen((isOpen) => !isOpen)
  }, [])

  const setManagerModalOpen = useCallback(() => {
    setIsManagerModalOpen(true)
  }, [])

  return (
    <>
      <button
        onClick={toggleIsDialogOpen}
        className={assembleClassNames(
          'filter-textColor6 p-2 rounded-3',
          isDialogOpen && 'bg-bootcamp-light-purple filter-none'
        )}
      >
        <GraphicalIcon icon="settings" />
      </button>
      {isDialogOpen && (
        <div
          tabIndex={-1}
          role="dialog"
          aria-label="Additional settings for bootcamp editor"
          className="settings-dialog"
        >
          <button onClick={setManagerModalOpen} className="btn-s btn-default">
            Manage custom functions
          </button>
        </div>
      )}

      <ManageCustomFunctionsModal
        isOpen={isManagerModalOpen}
        setIsOpen={setIsManagerModalOpen}
      />
    </>
  )
}
