import React from 'react'
import { Task } from '../types'
import { Summary } from './task-tooltip/Summary'
import { TypeInfo } from './task-tooltip/TypeInfo'
import { ActionInfo } from './task-tooltip/ActionInfo'
import { SizeInfo } from './task-tooltip/SizeInfo'
import { KnowledgeInfo } from './task-tooltip/KnowledgeInfo'
import { ModuleInfo } from './task-tooltip/ModuleInfo'

export const TaskTooltip = ({ task }: { task: Task }): JSX.Element | null => {
  return (
    <div className="c-task-tooltip">
      <Summary task={task} />
      {task.tags.type ? <TypeInfo type={task.tags.type} /> : null}
      {task.tags.action ? <ActionInfo action={task.tags.action} /> : null}
      {task.tags.size ? <SizeInfo size={task.tags.size} /> : null}
      {task.tags.knowledge ? (
        <KnowledgeInfo
          knowledge={task.tags.knowledge}
          module={task.tags.module}
        />
      ) : null}
      {task.tags.module ? <ModuleInfo module={task.tags.module} /> : null}
    </div>
  )
}
