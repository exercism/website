import React, { useCallback, useContext, useState } from 'react'
import Modal from 'react-modal'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { SolveExercisePageContext } from '../SolveExercisePageContextWrapper'

export function ResetButton() {
  const [shouldOpenConfirmationModal, setShouldOpenConfirmationModal] =
    useState(false)
  const { resetEditorToStub } = useContext(SolveExercisePageContext)

  const handleResetEditorToStub = useCallback(() => {
    resetEditorToStub()
    setShouldOpenConfirmationModal(false)
  }, [resetEditorToStub, setShouldOpenConfirmationModal])

  return (
    <>
      <button
        onClick={() => setShouldOpenConfirmationModal(true)}
        className={assembleClassNames('btn-secondary btn-xxs ml-8')}
      >
        Reset
      </button>

      {/* @ts-ignore */}
      <Modal
        isOpen={shouldOpenConfirmationModal}
        className="solve-exercise-page-react-modal-content flex flex-col items-center justify-center text-center max-w-[500px]"
        overlayClassName="solve-exercise-page-react-modal-overlay"
      >
        <h2 className="text-[25px] mb-12 font-semibold">Are you sure?</h2>
        <p className="text-16 mb-10">
          Are you sure you want to reset the exercise to the starting code?
          You'll lose all your progress.
        </p>

        <div className="flex items-center gap-8 self-stretch">
          <button
            onClick={handleResetEditorToStub}
            className="btn-l btn-primary"
          >
            Reset code to stub
          </button>
          <button
            onClick={() => setShouldOpenConfirmationModal(false)}
            className="btn-l btn-standard flex-grow"
          >
            Cancel
          </button>
        </div>
      </Modal>
    </>
  )
}
