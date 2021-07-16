import React from 'react'
import { Task as TaskProps } from '../../types'
import { ActionIcon } from './task/ActionIcon'
import { NewTag } from './task/NewTag'
import { TrackType } from './task/TrackType'
import { KnowledgeTag } from './task/KnowledgeTag'
import { SizeTag } from './task/SizeTag'
import { ModuleTag } from './task/ModuleTag'
import { GraphicalIcon } from '../../common'
import { LazyTippy } from '../../misc/LazyTippy'
import { followCursor } from 'tippy.js'
import { TaskTooltip } from '../../tooltips/TaskTooltip'

export const Task = ({ task }: { task: TaskProps }): JSX.Element => {
  return (
    <LazyTippy
      content={<TaskTooltip endpoint={task.links.tooltip} />}
      animation="shift-away-subtle"
      followCursor="horizontal"
      maxWidth="none"
      plugins={[followCursor]}
    >
      <a
        href={task.links.githubUrl}
        className="task"
        target="_blank"
        rel="noreferrer"
      >
        <ActionIcon action={task.tags.action} />
        <div className="info">
          <div className="heading">
            <h3>{task.title}</h3>
            {task.isNew ? <NewTag /> : null}
          </div>
          <TrackType track={task.track} type={task.tags.type} />
        </div>
        <div className="tags">
          <KnowledgeTag knowledge={task.tags.knowledge} />
          <SizeTag size={task.tags.size} />
          <ModuleTag module={task.tags.module} />
        </div>
        <GraphicalIcon icon="external-link" className="external-link" />
      </a>
    </LazyTippy>
  )
}
