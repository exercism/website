import React, { useContext } from 'react'
import Modal from 'react-modal'
import { CompletedBonusTasksView } from './CompletedBonusTasksView'
import { FinishLessonModalContext } from '../FinishLessonModal/FinishLessonModalContextWrapper'

Modal.setAppElement('body')

// show when original modal was shown, and testResults status is pass_bonus
export function CompletedBonusTasksModal() {
  const { isCompletedBonusTasksModalOpen } = useContext(
    FinishLessonModalContext
  )

  return (
    // @ts-ignore
    <Modal
      isOpen={isCompletedBonusTasksModalOpen}
      className="solve-exercise-page-react-modal-content flex flex-col items-center justify-center text-center max-w-[540px]"
      overlayClassName="solve-exercise-page-react-modal-overlay"
    >
      <CompletedBonusTasksView />
    </Modal>
  )
}
