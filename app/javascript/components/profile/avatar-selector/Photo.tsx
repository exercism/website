import React from 'react'
import { Avatar } from '../../common'
import { DeletePhotoButton } from './photo/DeletePhotoButton'
import { User } from '../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

type Links = {
  delete: string
}

export const Photo = ({
  user,
  onAttach,
  onDelete,
  links,
}: {
  user: User
  onAttach: (e: React.ChangeEvent<HTMLInputElement>) => void
  onDelete: (user: User) => void
  links: Links
}): JSX.Element => {
  const { t } = useAppTranslation('components/profile/avatar-selector')

  return (
    <div className="c-avatar-selector">
      <label htmlFor="avatar">
        <Avatar handle={user.handle} src={user.avatarUrl} />
      </label>
      <div className="--details">
        <h2>{t('photo.yourProfilePicture')}</h2>
        <div className="faux-button">
          <div className="btn btn-enhanced btn-s">
            {t('photo.uploadNewImage')}
          </div>
          <input type="file" id="avatar" onChange={onAttach} />
          <div className="hover-bg" />
        </div>
        <div className="cropping">{t('photo.cropping')}</div>
        {user.hasAvatar ? (
          <div className="deleting">
            <Trans
              ns="components/profile/avatar-selector"
              i18nKey="photo.youCanAlso"
              components={{
                deleteButton: (
                  <DeletePhotoButton links={links} onDelete={onDelete} />
                ),
              }}
            />
          </div>
        ) : null}
      </div>
    </div>
  )
}
