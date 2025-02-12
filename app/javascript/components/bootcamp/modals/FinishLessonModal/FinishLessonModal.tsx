import React from 'react'
import Modal from 'react-modal'
import { FinishLessonModalContext } from './FinishLessonModalContextWrapper'
import { useContext } from 'react'
import { InitialView } from './views/InitialView'
import { CompletedExerciseView } from './views/CompletedExerciseView'
import { CompletedLevelView } from './views/CompletedLevelView'

Modal.setAppElement('body')
export function FinishLessonModal() {
  const { isFinishLessonModalOpen: isOpen } = useContext(
    FinishLessonModalContext
  )

  return (
    // @ts-ignore
    <Modal
      isOpen={isOpen}
      className="solve-exercise-page-react-modal-content flex flex-col items-center justify-center text-center max-w-[540px]"
      overlayClassName="solve-exercise-page-react-modal-overlay"
    >
      <Inner />
    </Modal>
  )
}

function Inner() {
  const { modalView } = useContext(FinishLessonModalContext)

  switch (modalView) {
    case 'initial':
      return <InitialView />
    case 'completedExercise':
      return <CompletedExerciseView />
    case 'completedLevel':
      return <CompletedLevelView />
  }
}
