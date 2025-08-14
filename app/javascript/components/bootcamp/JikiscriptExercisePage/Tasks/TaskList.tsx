// i18n-key-prefix: taskList
// i18n-namespace: components/bootcamp/JikiscriptExercisePage/Tasks
import React from 'react'
import LottieAnimation from '@/components/bootcamp/common/LottieAnimation'
import useTaskStore from '../store/taskStore/taskStore'
import confettiAnimation from '@/../animations/confetti.json'
import { Icon } from '@/components/common/Icon'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function TaskList({ tasks }: { tasks: Task[] }) {
  const { setCurrentTaskIndex } = useTaskStore()
  return tasks.map((task, idx) => (
    <Task
      onClick={() => setCurrentTaskIndex(idx)}
      task={task}
      key={`task-${idx}`}
    />
  ))
}

function Task({ task, onClick }: { task: Task; onClick: () => void }) {
  const { t } = useAppTranslation(
    'components/bootcamp/JikiscriptExercisePage/Tasks'
  )
  return (
    <div data-ci="task" className={`task ${task.status}`}>
      <div className="imgs">
        <Icon
          icon="bootcamp-task-completed"
          alt={t('taskList.completed')}
          className="completed-icon"
        />
        <Icon
          icon="bootcamp-task-pending"
          alt={t('taskList.pending')}
          className="pending-icon"
        />

        {task.status == 'completed' && (
          <LottieAnimation
            animationData={confettiAnimation}
            className="confetti"
            loop={false}
          />
        )}
      </div>

      <button onClick={onClick}>{task.name}</button>
    </div>
  )
}
