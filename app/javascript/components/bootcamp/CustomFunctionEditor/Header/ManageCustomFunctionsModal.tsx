import React, { useCallback, useContext, useMemo } from 'react'
import Modal from 'react-modal'
import useCustomFunctionStore, {
  CustomFunctionForInterpreter,
  CustomFunctionMetadata,
} from '../store/customFunctionsStore'
import { useLogger } from '@/hooks'
import {
  CustomFunctionLinks,
  SolveExercisePageContext,
} from '../../SolveExercisePage/SolveExercisePageContextWrapper'

Modal.setAppElement('body')

export function ManageCustomFunctionsModal({ isOpen }) {
  const {
    customFunctionMetadataCollection,
    customFunctionsForInterpreter,
    addCustomFunctionsForInterpreter,
    removeCustomFunctionsForInterpreter,
  } = useCustomFunctionStore()

  const { links } = useContext(SolveExercisePageContext) as {
    links: CustomFunctionLinks
  }

  useLogger('custom md', customFunctionMetadataCollection)
  useLogger('custom fn for interpreter', customFunctionsForInterpreter)

  const hasMetadata = useMemo(
    () => customFunctionMetadataCollection.length > 0,
    [customFunctionMetadataCollection]
  )

  const getIsFunctionImported = useCallback(
    (uuid: string) => {
      return (
        customFunctionsForInterpreter.findIndex(
          (customFn) => customFn.slug === uuid
        ) > -1
      )
    },
    [customFunctionsForInterpreter]
  )

  const handleGetCustomFunctionForInterpreter = useCallback(
    async (slug: string) => {
      const data = await getCustomFunctionsForInterpreter(
        links.getCustomFnsForInterpreter,
        slug
      )

      const [firstFn] = data.custom_functions
      addCustomFunctionsForInterpreter({ ...firstFn, slug })

      console.log('DATA', data)
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
                key={customFnMetadata.slug}
                onClick={() =>
                  getIsFunctionImported(customFnMetadata.slug)
                    ? handleRemoveCustomFunctionForInterpreter(
                        customFnMetadata.slug
                      )
                    : handleGetCustomFunctionForInterpreter(
                        customFnMetadata.slug
                      )
                }
                buttonLabel={
                  getIsFunctionImported(customFnMetadata.slug)
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
        <button className="btn-secondary btn-m">Close</button>
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
      <div>{customFnMetadata.slug}</div>
      <button className="btn btn-primary" onClick={onClick}>
        <code>{buttonLabel}</code>
      </button>
    </div>
  )
}

export async function getCustomFunctionsForInterpreter(
  url: string,
  slug: string
): Promise<{ custom_functions: CustomFunctionForInterpreter[] }> {
  // bootcamp/custom_functions/for_interpreter?uuids=123,234,345
  const response = await fetch(url + '?uuids=' + slug, {
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
