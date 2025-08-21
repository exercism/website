// i18n-key-prefix:
// i18n-namespace: components/settings/PhotoForm.tsx
import React from 'react'
import { User } from '../types'
import { AvatarSelector } from '../profile'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type Links = {
  update: string
  delete: string
}

export default function PhotoForm({
  defaultUser,
  links,
}: {
  defaultUser: User
  links: Links
}): JSX.Element {
  const { t } = useAppTranslation('components/settings/PhotoForm.tsx')
  return (
    <div className="c-settings-photo-form">
      <h2>{t('photoForm.changeYourPhoto')}</h2>
      <hr className="c-divider --small" />
      <AvatarSelector defaultUser={defaultUser} links={links} />
    </div>
  )
}
