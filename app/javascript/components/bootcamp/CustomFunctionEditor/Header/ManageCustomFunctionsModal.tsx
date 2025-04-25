import React, { useCallback, useContext, useMemo } from 'react'
import Modal from 'react-modal'
import useCustomFunctionStore from '../store/customFunctionsStore'
import { JikiscriptExercisePageContext } from '../../JikiscriptExercisePage/JikiscriptExercisePageContextWrapper'
import { GraphicalIcon } from '@/components/common'
import { CustomFunctionContext } from '../CustomFunctionEditor'
import { assembleClassNames } from '@/utils/assemble-classnames'

Modal.setAppElement('body')

type CustomFunctionMetadata = {
  name: string
  description: string
}

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
    availableCustomFunctions,
    getIsFunctionActivated,
    activateCustomFunction,
    deactivateCustomFunction,
  } = useCustomFunctionStore()

  const { links } = useContext(JikiscriptExercisePageContext)

  const hasMetadata = useMemo(
    () => Object.keys(availableCustomFunctions).length > 0,
    [availableCustomFunctions]
  )

  const handleActivateCustomFunction = useCallback(
    async (name: string) => {
      activateCustomFunction(name)
      if (onChange) {
        onChange()
      }
    },
    [links, onChange]
  )
  const handleDeactivateCustomFunction = useCallback(
    (name: string) => {
      deactivateCustomFunction(name)
      if (onChange) {
        onChange()
      }
    },
    [onChange]
  )

  return (
    // @ts-ignore
    <Modal
      isOpen={isOpen}
      className="solve-exercise-page-react-modal-content custom-function-selector flex flex-col w-fill max-w-[540px]"
      overlayClassName="solve-exercise-page-react-modal-overlay"
    >
      <h2 className="text-h3">Import Library Functions</h2>
      <p className="text-p-large mb-12">
        Select the library functions you want to make available to use in your
        code.
      </p>
      <div className="flex flex-col gap-8 mb-12 overflow-y-auto mr-[-32px] pr-32">
        {hasMetadata ? (
          Object.values(availableCustomFunctions).map((customFnMetadata) => {
            return (
              <CustomFunctionMetadata
                key={customFnMetadata.name}
                dependsOnCurrentFunction={
                  customFnMetadata.dependsOnCurrentFunction
                }
                onClick={() => {
                  return getIsFunctionActivated(customFnMetadata.name)
                    ? handleDeactivateCustomFunction(customFnMetadata.name)
                    : handleActivateCustomFunction(customFnMetadata.name)
                }}
                buttonClass={
                  getIsFunctionActivated(customFnMetadata.name)
                    ? 'selected'
                    : ''
                }
                customFnMetadata={customFnMetadata}
              />
            )
          })
        ) : (
          <div>There are no library functions yet.</div>
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
  dependsOnCurrentFunction,
}: {
  customFnMetadata: CustomFunctionMetadata
  onClick: () => void
  buttonClass: string
  dependsOnCurrentFunction?: boolean
}) {
  return (
    <button
      disabled={dependsOnCurrentFunction}
      className={assembleClassNames(
        'row',
        buttonClass,
        dependsOnCurrentFunction && 'disabled'
      )}
      onClick={onClick}
    >
      <div className="circle"></div>
      <GraphicalIcon icon="completed-check-circle" width={24} height={24} />
      <div>
        <h3 className="text-h6 mb-2">{customFnMetadata.name}</h3>
        <p className="text-p-base">{customFnMetadata.description}</p>
        {dependsOnCurrentFunction && <DependsOnCurrentFunctionText />}
      </div>
    </button>
  )
}

function DependsOnCurrentFunctionText() {
  const customFunction = useContext(CustomFunctionContext)

  if (!customFunction) {
    return null
  }

  return (
    <div className="mt-8 font-semibold text-[#cc5500]">
      This function depends on <code>{customFunction.name}</code>, so it cannot
      be imported.
    </div>
  )
}
