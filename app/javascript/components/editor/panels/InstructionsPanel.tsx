import React, { useContext, useEffect, useRef, useState } from 'react'
import { Tab } from '../../common/Tab'
import { TabsContext, TasksContext } from '../../Editor'
import { Assignment, AssignmentTask } from '../types'
import { TaskHintsModal } from '../../modals/TaskHintsModal'
import { GraphicalIcon, Icon } from '../../common'
import { useHighlighting } from '../../../utils/highlight'
import { useReducedMotion } from '../../../hooks/use-reduced-motion'
import VimeoEmbed from '../../common/VimeoEmbed'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const InstructionsPanel = ({
  introduction,
  assignment,
  debuggingInstructions,
  tutorial = false,
}: {
  introduction: string
  assignment: Assignment
  debuggingInstructions?: string
  tutorial?: boolean
}): JSX.Element => {
  const { t } = useAppTranslation('components/editor/panels')
  const ref = useHighlighting<HTMLDivElement>()

  return (
    <Tab.Panel id="instructions" context={TabsContext} alwaysAttachToDOM>
      <section className="instructions-pane" ref={ref}>
        <div className="c-textual-content --base">
          {tutorial && <HelloWorldVideo />}
          <Introduction introduction={introduction} />
          <Instructions assignment={assignment} />
          <Debug debuggingInstructions={debuggingInstructions} />
        </div>
      </section>
    </Tab.Panel>
  )
}

function HelloWorldVideo() {
  const { t } = useAppTranslation('components/editor/panels')
  return (
    <>
      <h2>{t('instructionsPanel.introduction')}</h2>
      <p className="mb-20">{t('instructionsPanel.watchOurVideo')}</p>
      <VimeoEmbed id="853440496?h=6abbdfc68f" className="rounded-5" />
    </>
  )
}

const Introduction = ({ introduction }: { introduction: string }) => {
  const { t } = useAppTranslation('components/editor/panels')
  if (
    introduction === undefined ||
    introduction === null ||
    introduction.length === 0
  ) {
    return null
  }

  return (
    <div className="introduction">
      <h2>{t('instructionsPanel.introduction')}</h2>
      <div
        className="content"
        dangerouslySetInnerHTML={{ __html: introduction }}
      />
    </div>
  )
}

const Instructions = ({ assignment }: { assignment: Assignment }) => {
  const { t } = useAppTranslation('components/editor/panels')

  return (
    <div className="instructions">
      <h2>{t('instructionsPanel.instructions')}</h2>
      <div
        className="content"
        dangerouslySetInnerHTML={{ __html: assignment.overview }}
      />

      {assignment.tasks.map((task, idx) => (
        <Task key={idx} task={task} idx={idx} />
      ))}
    </div>
  )
}

const Task = ({ task, idx }: { task: AssignmentTask; idx: number }) => {
  const { current } = useContext(TasksContext)
  const [isModalOpen, setIsModalOpen] = useState(false)
  const detailsRef = useRef<HTMLDetailsElement>(null)
  const detailsProps =
    (current === null && idx === 0) || current === task.id ? { open: true } : {}
  const reducedMotion = useReducedMotion()
  const { t } = useAppTranslation('components/editor/panels')

  useEffect(() => {
    if (detailsRef?.current && current === task.id) {
      detailsRef.current.scrollIntoView(
        reducedMotion ? {} : { behavior: 'smooth' }
      )
    }
  }, [current, detailsRef])

  return (
    <details ref={detailsRef} className="c-details task" {...detailsProps}>
      <summary className="--summary">
        <div className="--summary-inner">
          <div className="task-marker">
            {t('instructionsPanel.task', { n: idx + 1 })}
          </div>
          <span className="summary-title">{task.title}</span>
          <span className="--closed-icon">
            <GraphicalIcon icon="chevron-right" />
          </span>
          <span className="--open-icon">
            <GraphicalIcon icon="chevron-down" />
          </span>
        </div>
      </summary>
      <div dangerouslySetInnerHTML={{ __html: task.text }} />

      <div>
        <TaskHintsModal
          task={task}
          open={isModalOpen}
          onClose={() => setIsModalOpen(false)}
        />
        <button
          className="btn-default btn-s hints-btn"
          onClick={() => {
            setIsModalOpen(true)
          }}
        >
          <span>{t('instructionsPanel.stuckRevealHints')}</span>
          <Icon icon="modal" alt={t('instructionsPanel.opensInAModal')} />
        </button>
      </div>
    </details>
  )
}

const Debug = ({
  debuggingInstructions,
}: {
  debuggingInstructions?: string
}) => {
  const { t } = useAppTranslation('components/editor/panels')

  if (
    debuggingInstructions === undefined ||
    debuggingInstructions === null ||
    debuggingInstructions.length === 0
  ) {
    return null
  }

  return (
    <div className="debug-info">
      <h2>{t('instructionsPanel.howToDebug')}</h2>
      <div dangerouslySetInnerHTML={{ __html: debuggingInstructions }} />
    </div>
  )
}
