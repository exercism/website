import GraphicalIcon from '@/components/common/GraphicalIcon'
import { assembleClassNames } from '@/utils/assemble-classnames'
import React, { useCallback, useContext, useState } from 'react'
import { ManageCustomFunctionsModal } from './ManageCustomFunctionsModal'
import { SolveExercisePageContext } from '../../SolveExercisePage/SolveExercisePageContextWrapper'
import useCustomFunctionStore, {
  CustomFunctionMetadata,
} from '../store/customFunctionsStore'

export function SettingsButton() {
  const [isDialogOpen, setIsDialogOpen] = useState(false)
  const [isManagerModalOpen, setIsManagerModalOpen] = useState(false)
  const [isFetchingCustomFns, setIsFetchingCustomFns] = useState(false)

  const { setCustomFunctionMetadataCollection } = useCustomFunctionStore()

  const toggleIsDialogOpen = useCallback(() => {
    setIsDialogOpen((isOpen) => !isOpen)
  }, [])

  const { links } = useContext(SolveExercisePageContext)

  const setManagerModalOpen = useCallback(() => {
    setIsManagerModalOpen(true)
    setIsDialogOpen(false)
    handleGetFunctions()
  }, [])

  const handleGetFunctions = useCallback(async () => {
    setIsFetchingCustomFns(true)
    const data = await getCustomFunctions(links.getCustomFns)

    setCustomFunctionMetadataCollection(data.custom_functions)
    setIsFetchingCustomFns(false)
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
        isFetching={isFetchingCustomFns}
        isOpen={isManagerModalOpen}
        setIsOpen={setIsManagerModalOpen}
      />
    </>
  )
}

export async function getCustomFunctions(
  url: string
): Promise<{ custom_functions: CustomFunctionMetadata[] }> {
  const response = await fetch(url, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
    },
    body: null,
  })

  if (!response.ok) {
    throw new Error('Failed to submit code')
  }

  return response.json()
}
