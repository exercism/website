// i18n-key-prefix: statePreview
// i18n-namespace: components/bootcamp/JikiscriptExercisePage/TaskPreview
import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'
export function StatePreview({
  inspectedPreviewTaskTest,
}: {
  inspectedPreviewTaskTest: TaskTest
}) {
  const { t } = useAppTranslation(
    'components/bootcamp/JikiscriptExercisePage/TaskPreview'
  )
  return (
    <div className="scenario-lhs">
      <div className="scenario-lhs-content">
        <h3>
          <strong>{t('statePreview.scenario')}</strong>
          {inspectedPreviewTaskTest.name}
        </h3>

        {inspectedPreviewTaskTest.descriptionHtml &&
          inspectedPreviewTaskTest.descriptionHtml.length > 0 && (
            <div className="description text-bootcamp-purple">
              <strong>{t('taskPreview.task')}</strong>
              <span
                dangerouslySetInnerHTML={{
                  __html: inspectedPreviewTaskTest.descriptionHtml ?? '',
                }}
              />
            </div>
          )}
      </div>
    </div>
  )
}
