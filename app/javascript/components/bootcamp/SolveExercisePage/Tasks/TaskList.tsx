import React from 'react'
import LottieAnimation from '@/components/bootcamp/common/LottieAnimation'
import useTaskStore from '../store/taskStore/taskStore'
import confettiAnimation from '@/../animations/confetti.json'

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
  return (
    <div data-cy="task" className={`task ${task.status}`}>
      <div className="imgs">
        <img src={'/task-completed.svg'} className="completed-icon" />
        <img src={'/task-pending.svg'} className="pending-icon" />

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
