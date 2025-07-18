// i18n-key-prefix: tasksList.knowledgeSwitcher
// i18n-namespace: components/contributing
import React from 'react'
import { TaskKnowledge } from '@/components/types'
import { GraphicalIcon } from '@/components/common'
import { MultipleSelect } from '@/components/common/MultipleSelect'
import { KnowledgeIcon } from './task/KnowledgeIcon'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const KnowledgeOption = ({
  option: knowledge,
}: {
  option: TaskKnowledge
}): JSX.Element => {
  const { t } = useAppTranslation('components/contributing')
  switch (knowledge) {
    case 'none':
      return (
        <React.Fragment>
          <div className="knowledge-tag">
            <KnowledgeIcon knowledge={knowledge} />
          </div>
          <div className="info">
            <div className="title">{t('tasksList.knowledgeSwitcher.none')}</div>
            <div className="description">
              No existing Exercism knowledge required
            </div>
          </div>
        </React.Fragment>
      )
    case 'elementary':
      return (
        <React.Fragment>
          <div className="knowledge-tag">
            <KnowledgeIcon knowledge={knowledge} />
          </div>
          <div className="info">
            <div className="title">
              {t('tasksList.knowledgeSwitcher.elementary')}
            </div>
            <div className="description">
              Little Exercism knowledge required
            </div>
          </div>
        </React.Fragment>
      )
    case 'intermediate':
      return (
        <React.Fragment>
          <div className="knowledge-tag">
            <KnowledgeIcon knowledge={knowledge} />
          </div>
          <div className="info">
            <div className="title">
              {t('tasksList.knowledgeSwitcher.intermediate')}
            </div>
            <div className="description">
              Quite a bit of Exercism knowledge required
            </div>
          </div>
        </React.Fragment>
      )
    case 'advanced':
      return (
        <React.Fragment>
          <div className="knowledge-tag">
            <KnowledgeIcon knowledge={knowledge} />
          </div>
          <div className="info">
            <div className="title">
              {t('tasksList.knowledgeSwitcher.advanced')}
            </div>
            <div className="description">
              Comprehensive Exercism knowledge required
            </div>
          </div>
        </React.Fragment>
      )
  }
}

const SelectedComponent = ({
  value: knowledge,
}: {
  value: TaskKnowledge[]
}) => {
  const { t } = useAppTranslation('components/contributing')
  if (knowledge.length > 1) {
    return <>Multiple</>
  }

  switch (knowledge[0]) {
    case 'none':
      return <>{t('tasksList.knowledgeSwitcher.none')}</>
    case 'elementary':
      return <>{t('tasksList.knowledgeSwitcher.elementary')}</>
    case 'intermediate':
      return <>{t('tasksList.knowledgeSwitcher.intermediate')}</>
    case 'advanced':
      return <>{t('tasksList.knowledgeSwitcher.advanced')}</>
    case undefined:
      return <>{t('tasksList.knowledgeSwitcher.anyKnowledge')}</>
  }
}

const ResetComponent = () => {
  const { t } = useAppTranslation('components/contributing')
  return (
    <React.Fragment>
      <GraphicalIcon
        icon="task-knowledge"
        className="task-icon knowledge-reset"
      />
      <div className="info">
        <div className="title">
          {t('tasksList.knowledgeSwitcher.anyKnowledge')}
        </div>
      </div>
    </React.Fragment>
  )
}

export const KnowledgeSwitcher = ({
  value,
  setValue,
}: {
  value: TaskKnowledge[]
  setValue: (knowledge: TaskKnowledge[]) => void
}): JSX.Element => {
  return (
    <MultipleSelect<TaskKnowledge>
      options={['none', 'elementary', 'intermediate', 'advanced']}
      value={value}
      setValue={setValue}
      label="Knowledge"
      SelectedComponent={SelectedComponent}
      ResetComponent={ResetComponent}
      OptionComponent={KnowledgeOption}
      className="knowledge-switcher"
    />
  )
}
