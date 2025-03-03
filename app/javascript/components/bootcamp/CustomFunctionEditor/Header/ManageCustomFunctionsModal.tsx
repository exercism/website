import React, { useCallback, useContext, useMemo } from 'react'
import Modal from 'react-modal'
import useCustomFunctionStore, {
  CustomFunctionMetadata,
} from '../store/customFunctionsStore'
import { SolveExercisePageContext } from '../../SolveExercisePage/SolveExercisePageContextWrapper'
import { GraphicalIcon } from '@/components/common'

Modal.setAppElement('body')

export function ManageCustomFunctionsModal({
  isOpen,
  setIsOpen,
  onChange,
}: {
  isOpen: boolean
  setIsOpen: React.Dispatch<React.SetStateAction<boolean>>
  onChange?: () => void
}) {
  const {
    customFunctionMetadataCollection,
    customFunctionsForInterpreter,
    addCustomFunctionsForInterpreter,
    removeCustomFunctionsForInterpreter,
  } = useCustomFunctionStore()

  const { links } = useContext(SolveExercisePageContext)

  const hasMetadata = useMemo(
    () => customFunctionMetadataCollection.length > 0,
    [customFunctionMetadataCollection]
  )

  const getIsFunctionImported = useCallback(
    (name: string) => {
      return (
        customFunctionsForInterpreter.findIndex(
          (customFn) => customFn.name === name
        ) > -1
      )
    },
    [customFunctionsForInterpreter]
  )

  const handleGetCustomFunctionForInterpreter = useCallback(
    async (name: string) => {
      console.log(name)
      const data = await getCustomFunctionsForInterpreter(
        links.getCustomFnsForInterpreter,
        name
      )

      const [firstFn] = data.custom_functions
      addCustomFunctionsForInterpreter({
        name: firstFn.name,
        arity: firstFn.arity,
        code: firstFn.code,
      })
      if (onChange) {
        onChange()
      }
    },
    []
  )
  const handleRemoveCustomFunctionForInterpreter = useCallback(
    async (uuid: string) => {
      removeCustomFunctionsForInterpreter(uuid)
      if (onChange) {
        onChange()
      }
    },
    []
  )

  return (
    // @ts-ignore
    <Modal
      isOpen={isOpen}
      className="solve-exercise-page-react-modal-content custom-function-selector flex flex-col w-fill max-w-[540px]"
      overlayClassName="solve-exercise-page-react-modal-overlay"
    >
      <h2 className="text-h3">Import Custom Functions</h2>
      <p className="text-p-large mb-12">
        Select the custom functions you want to make available to use in your
        code.
      </p>
      <div className="flex flex-col gap-8 mb-12 overflow-y-auto mr-[-32px] pr-32">
        {hasMetadata ? (
          customFunctionMetadataCollection.map((customFnMetadata) => {
            return (
              <CustomFunctionMetadata
                key={customFnMetadata.name}
                onClick={() => {
                  return getIsFunctionImported(customFnMetadata.name)
                    ? handleRemoveCustomFunctionForInterpreter(
                        customFnMetadata.name
                      )
                    : handleGetCustomFunctionForInterpreter(
                        customFnMetadata.name
                      )
                }}
                buttonClass={
                  getIsFunctionImported(customFnMetadata.name) ? 'selected' : ''
                }
                customFnMetadata={customFnMetadata}
              />
            )
          })
        ) : (
          <div>There are no custom functions yet.</div>
        )}
      </div>
      <button onClick={() => setIsOpen(false)} className="btn-default btn-m">
        Save & Close
      </button>
    </Modal>
  )
}

function CustomFunctionMetadata({
  customFnMetadata,
  onClick,
  buttonClass,
}: {
  customFnMetadata: CustomFunctionMetadata
  onClick: () => void
  buttonClass: string
}) {
  return (
    <button className={`row ${buttonClass}`} onClick={onClick}>
      <div className="circle"></div>
      <GraphicalIcon icon="completed-check-circle" width={24} height={24} />
      <div>
        <h3 className="text-h6 mb-2">{customFnMetadata.name}</h3>
        <p className="text-p-base">{customFnMetadata.description}</p>
      </div>
    </button>
  )
}

export async function getCustomFunctionsForInterpreter(
  url: string,
  name: string
): Promise<{
  custom_functions: {
    code: string
    arity: number
    name: string
  }[]
}> {
  // bootcamp/custom_functions/for_interpreter?uuids=123,234,345
  const response = await fetch(url + '?name=' + encodeURIComponent(name), {
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
