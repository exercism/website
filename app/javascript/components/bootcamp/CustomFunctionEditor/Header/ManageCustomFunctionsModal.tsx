import React, { useCallback, useContext, useMemo } from 'react'
import Modal from 'react-modal'
import useCustomFunctionStore, {
  CustomFunctionMetadata,
} from '../store/customFunctionsStore'
import { SolveExercisePageContext } from '../../SolveExercisePage/SolveExercisePageContextWrapper'

Modal.setAppElement('body')

export function ManageCustomFunctionsModal({
  isOpen,
  setIsOpen,
}: {
  isOpen: boolean
  setIsOpen: React.Dispatch<React.SetStateAction<boolean>>
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
      const data = await getCustomFunctionsForInterpreter(
        links.getCustomFnsForInterpreter,
        name
      )

      const [firstFn] = data.custom_functions
      addCustomFunctionsForInterpreter({
        arity: firstFn.fn_arity,
        code: firstFn.code,
        name: firstFn.name,
        fnName: firstFn.fn_name,
      })
    },
    []
  )
  const handleRemoveCustomFunctionForInterpreter = useCallback(
    async (uuid: string) => {
      removeCustomFunctionsForInterpreter(uuid)
    },
    []
  )

  return (
    // @ts-ignore
    <Modal
      isOpen={isOpen}
      className="solve-exercise-page-react-modal-content flex flex-col items-center justify-center text-center max-w-[540px]"
      overlayClassName="solve-exercise-page-react-modal-overlay"
    >
      <div className="flex flex-col gap-8">
        {hasMetadata ? (
          customFunctionMetadataCollection.map((customFnMetadata) => {
            return (
              <CustomFunctionMetadata
                key={customFnMetadata.name}
                onClick={() =>
                  getIsFunctionImported(customFnMetadata.name)
                    ? handleRemoveCustomFunctionForInterpreter(
                        customFnMetadata.name
                      )
                    : handleGetCustomFunctionForInterpreter(
                        customFnMetadata.name
                      )
                }
                buttonLabel={
                  getIsFunctionImported(customFnMetadata.name)
                    ? 'remove'
                    : 'import'
                }
                customFnMetadata={customFnMetadata}
              />
            )
          })
        ) : (
          <div>There are no custom functions yet.</div>
        )}
        <button
          onClick={() => setIsOpen(false)}
          className="btn-secondary btn-m"
        >
          Close
        </button>
      </div>
    </Modal>
  )
}

function CustomFunctionMetadata({
  customFnMetadata,
  onClick,
  buttonLabel,
}: {
  customFnMetadata: CustomFunctionMetadata
  onClick: () => void
  buttonLabel: string
}) {
  return (
    <div className="border border-1 border-textColor6 rounded-5 text-left p-4">
      <div>
        <strong>{customFnMetadata.name}</strong>
      </div>
      <div>{customFnMetadata.description}</div>
      <button className="btn btn-primary" onClick={onClick}>
        <code>{buttonLabel}</code>
      </button>
    </div>
  )
}

export async function getCustomFunctionsForInterpreter(
  url: string,
  name: string
): Promise<{
  custom_functions: {
    code: string
    fn_arity: number
    fn_name: string
    name: string
  }[]
}> {
  // bootcamp/custom_functions/for_interpreter?uuids=123,234,345
  const response = await fetch(url + '?name=' + name, {
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
