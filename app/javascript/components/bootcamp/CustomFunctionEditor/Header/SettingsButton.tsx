import GraphicalIcon from '@/components/common/GraphicalIcon'
import { assembleClassNames } from '@/utils/assemble-classnames'
import React, { useCallback, useState } from 'react'

export function SettingsButton() {
  const [isDialogOpen, setIsDialogOpen] = useState(false)

  const toggleIsDialogOpen = useCallback(() => {
    setIsDialogOpen((dopen) => !dopen)
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
          <button className="btn-s btn-default">Manage custom functions</button>
        </div>
      )}
    </>
  )
}
