// i18n-key-prefix: getHelpPanelComponents.getHelpPanelHints
// i18n-namespace: components/editor/GetHelp
import React from 'react'
import { GetHelpPanelProps } from '../GetHelpPanel'
import { GetHelpAccordionSkeleton } from './GetHelpAccordionSkeleton'
import { Hints } from './Hints'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function GetHelpPanelHints({
  assignment,
}: Pick<GetHelpPanelProps, 'assignment'>): JSX.Element | null {
  const { t } = useAppTranslation('components/editor/GetHelp')
  if (assignment.generalHints.length === 0 && assignment.tasks.length === 0) {
    return null
  }

  return (
    <GetHelpAccordionSkeleton title="Hints and Tips" className="hints">
      <>
        <div className="pt-8 flex flex-col gap-2">
          <p className="text-p-base text-color-2 mb-8">
            {t('getHelpPanelComponents.getHelpPanelHints.stuckHintsWillGive')}
          </p>
          <p className="text-p-base text-color-2">
            {t('getHelpPanelComponents.getHelpPanelHints.clickHeadingExpand')}
          </p>
        </div>
        <Hints
          hints={assignment.generalHints}
          heading={t('getHelpPanelComponents.getHelpPanelHints.general')}
          expanded={assignment.tasks.length === 0}
          collapsable={assignment.tasks.length > 0}
        />
        {assignment.tasks.map((task, idx) => (
          <Hints
            key={idx}
            hints={task.hints}
            heading={`Task ${idx + 1}. ${task.title}`}
            expanded={false}
            collapsable={true}
          />
        ))}
      </>
    </GetHelpAccordionSkeleton>
  )
}
