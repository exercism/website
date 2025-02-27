import React, { useCallback, useContext, useMemo } from 'react'
import Modal from 'react-modal'
import useCustomFunctionStore, {
  CustomFunctionMetadata,
} from '../store/customFunctionsStore'
import { SolveExercisePageContext } from '../../SolveExercisePage/SolveExercisePageContextWrapper'

Modal.setAppElement('body')

export function ManageCustomFunctionsModal({
  isOpen,
  isFetching,
  setIsOpen,
}: {
  isOpen: boolean
  isFetching: boolean
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
    (uuid: string) => {
      return (
        customFunctionsForInterpreter.findIndex(
          (customFn) => customFn.uuid === uuid
        ) > -1
      )
    },
    [customFunctionsForInterpreter]
  )

  const handleGetCustomFunctionForInterpreter = useCallback(
    async (uuid: string) => {
      const data = await getCustomFunctionsForInterpreter(
        links.getCustomFnsForInterpreter,
        uuid
      )

      const [firstFn] = data.custom_functions
      addCustomFunctionsForInterpreter({
        arity: firstFn.fn_arity,
        code: firstFn.code,
        name: firstFn.fn_name,
        uuid,
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
        {isFetching && <div>Loading custom function metadata...</div>}
        {hasMetadata ? (
          customFunctionMetadataCollection.map((customFnMetadata) => {
            return (
              <CustomFunctionMetadata
                key={customFnMetadata.uuid}
                onClick={() =>
                  getIsFunctionImported(customFnMetadata.uuid)
                    ? handleRemoveCustomFunctionForInterpreter(
                        customFnMetadata.uuid
                      )
                    : handleGetCustomFunctionForInterpreter(
                        customFnMetadata.uuid
                      )
                }
                buttonLabel={
                  getIsFunctionImported(customFnMetadata.uuid)
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
      <div>{customFnMetadata.uuid}</div>
      <button className="btn btn-primary" onClick={onClick}>
        <code>{buttonLabel}</code>
      </button>
    </div>
  )
}

export async function getCustomFunctionsForInterpreter(
  url: string,
  uuid: string
): Promise<{
  custom_functions: {
    code: string
    fn_arity: number
    fn_name: string
  }[]
}> {
  // bootcamp/custom_functions/for_interpreter?uuids=123,234,345
  const response = await fetch(url + '?uuids=' + uuid, {
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
