// i18n-key-prefix: toggleMoreInformationButton
// i18n-namespace: components/mentoring/session/student-info
import React from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import Icon from '@/components/common/Icon'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function ToggleMoreInformationButton({
  onClick,
  rotate,
}: {
  onClick: () => void
  rotate?: boolean
}) {
  const { t } = useAppTranslation('components/mentoring/session/student-info')
  return (
    <button
      className="self-stretch flex justify-center items-center mt-8 -mx-24 -mb-16 py-4 bg-backgroundColorD"
      onClick={onClick}
    >
      <Icon
        icon="chevron-down"
        alt={t('toggleMoreInformationButton.expand')}
        height={16}
        width={16}
        className={assembleClassNames(
          rotate ? 'rotate-180' : '',
          'filter-textColor6'
        )}
      />
    </button>
  )
}
