import React, { useCallback, useContext, useState } from 'react'
import Modal from 'react-modal'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { FrontendExercisePageContext } from '../FrontendExercisePageContext'
import { useAppTranslation } from '@/i18n/useAppTranslation'

Modal.setAppElement('body')
export function ResetButton() {
  const { t } = useAppTranslation(
    'components/bootcamp/FrontendExercisePage/Header'
  )
  const [shouldOpenConfirmationModal, setShouldOpenConfirmationModal] =
    useState(false)

  const { resetEditors } = useContext(FrontendExercisePageContext)

  const handleResetExercise = useCallback(() => {
    resetEditors()
    setShouldOpenConfirmationModal(false)
  }, [])

  return (
    <>
      <button
        onClick={() => setShouldOpenConfirmationModal(true)}
        className={assembleClassNames('btn-default btn-xxs')}
      >
        {t('resetButton.reset')}
      </button>

      {/* @ts-ignore */}
      <Modal
        ariaHideApp={false}
        isOpen={shouldOpenConfirmationModal}
        className="solve-exercise-page-react-modal-content flex flex-col items-center justify-center text-center max-w-[500px]"
        overlayClassName="solve-exercise-page-react-modal-overlay"
      >
        <h2 className="text-[25px] leading-140 mb-12 font-semibold">
          {t('resetButton.areYouSure')}
        </h2>
        <p className="text-18 leading-140 mb-16">
          {t(
            'resetButton.areYouSureYouWantToResetToTheStartingCodeYoullLoseYourProgressOnThisExercise'
          )}
        </p>

        <div className="flex items-center gap-8 self-stretch">
          <button
            onClick={() => setShouldOpenConfirmationModal(false)}
            className="btn-l btn-secondary !px-40 flex-shrink-0"
          >
            {t('resetButton.cancel')}
          </button>
          <button
            onClick={handleResetExercise}
            className="btn-l btn-primary flex-grow"
          >
            {t('resetButton.yesResetExercise')}
          </button>
        </div>
      </Modal>
    </>
  )
}
