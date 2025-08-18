// i18n-key-prefix: contributorsList.categorySwitcher
// i18n-namespace: components/contributing
import React from 'react'
import { SingleSelect } from '@/components/common/SingleSelect'
import { Category } from '../ContributorsList'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const OptionComponent = ({
  option: category,
}: {
  option: Category
}): JSX.Element => {
  const { t } = useAppTranslation('components/contributing')
  switch (category) {
    case 'authoring':
      return (
        <React.Fragment>
          <div className="info">
            <div className="title">
              {t('contributorsList.categorySwitcher.authoring')}
            </div>
          </div>
        </React.Fragment>
      )
    case 'building':
      return (
        <React.Fragment>
          <div className="info">
            <div className="title">
              {t('contributorsList.categorySwitcher.building')}
            </div>
          </div>
        </React.Fragment>
      )
    case 'maintaining':
      return (
        <React.Fragment>
          <div className="info">
            <div className="title">
              {t('contributorsList.categorySwitcher.maintaining')}
            </div>
          </div>
        </React.Fragment>
      )
    case 'mentoring':
      return (
        <React.Fragment>
          <div className="info">
            <div className="title">
              {t('contributorsList.categorySwitcher.mentoring')}
            </div>
          </div>
        </React.Fragment>
      )
    case undefined:
      return (
        <React.Fragment>
          <div className="info">
            <div className="title">
              {t('contributorsList.categorySwitcher.allCategories')}
            </div>
          </div>
        </React.Fragment>
      )
  }
}

const SelectedComponent = ({ option: category }: { option: Category }) => {
  const { t } = useAppTranslation('components/contributing')
  switch (category) {
    case 'authoring':
      return <>{t('contributorsList.categorySwitcher.authoring')}</>
    case 'building':
      return <>{t('contributorsList.categorySwitcher.building')}</>
    case 'mentoring':
      return <>{t('contributorsList.categorySwitcher.mentoring')}</>
    case 'maintaining':
      return <>{t('contributorsList.categorySwitcher.maintaining')}</>
    case undefined:
      return <>{t('contributorsList.categorySwitcher.allCategories')}</>
  }
}
export const CategorySwitcher = ({
  value,
  setValue,
}: {
  value: Category
  setValue: (value: Category) => void
}): JSX.Element => {
  return (
    <SingleSelect<Category>
      options={[undefined, 'building', 'authoring', 'maintaining', 'mentoring']}
      value={value}
      setValue={setValue}
      SelectedComponent={SelectedComponent}
      OptionComponent={OptionComponent}
    />
  )
}
