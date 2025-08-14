import React from 'react'
import { SingleSelect } from '@/components/common/SingleSelect'
import { ContributionCategoryId } from '@/components/types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const OptionComponent = ({
  option: category,
}: {
  option: ContributionCategoryId | undefined
}): JSX.Element => {
  const { t } = useAppTranslation('components/journey/contributions-list')

  switch (category) {
    case 'authoring':
      return (
        <div className="info">
          <div className="title">
            {t('categorySelect.contributingToExercises')}
          </div>
        </div>
      )
    case 'building':
      return (
        <div className="info">
          <div className="title">{t('categorySelect.buildingExercism')}</div>
        </div>
      )
    case 'maintaining':
      return (
        <div className="info">
          <div className="title">{t('categorySelect.maintaining')}</div>
        </div>
      )
    case 'mentoring':
      return (
        <div className="info">
          <div className="title">{t('categorySelect.mentoring')}</div>
        </div>
      )
    case 'publishing':
      return (
        <div className="info">
          <div className="title">{t('categorySelect.publishing')}</div>
        </div>
      )
    case 'other':
      return (
        <div className="info">
          <div className="title">{t('categorySelect.other')}</div>
        </div>
      )
    case undefined:
      return (
        <div className="info">
          <div className="title">{t('categorySelect.anyCategory')}</div>
        </div>
      )
  }
}

const SelectedComponent = () => {
  const { t } = useAppTranslation('components/journey/contributions-list')
  return <>{t('categorySelect.category')}</>
}

export const CategorySelect = ({
  value,
  setValue,
}: {
  value: ContributionCategoryId | undefined
  setValue: (value: ContributionCategoryId | undefined) => void
}): JSX.Element => {
  return (
    <SingleSelect<ContributionCategoryId | undefined>
      options={[
        undefined,
        'building',
        'authoring',
        'maintaining',
        'mentoring',
        'publishing',
        'other',
      ]}
      value={value}
      setValue={setValue}
      SelectedComponent={SelectedComponent}
      OptionComponent={OptionComponent}
    />
  )
}
