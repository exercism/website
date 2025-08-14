// i18n-key-prefix: insiderBubble
// i18n-namespace: components/settings/github-syncer/common
import GraphicalIcon from '@/components/common/GraphicalIcon'
import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function InsiderBubble() {
  const { t } = useAppTranslation('components/settings/github-syncer/common')
  return (
    <div className="flex items-center gap-8 rounded-100 font-medium bg-bootcamp-light-purple text-purple border-1 border-purple py-4 px-8 whitespace-nowrap">
      <GraphicalIcon icon="insiders" height={16} width={16} />
      {t('insiderBubble.insidersOnly')}
    </div>
  )
}
