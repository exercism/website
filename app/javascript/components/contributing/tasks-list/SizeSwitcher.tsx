// i18n-namespace: components/contributing
import React from 'react'
import { TaskSize } from '@/components/types'
import { GraphicalIcon } from '@/components/common'
import { MultipleSelect } from '@/components/common/MultipleSelect'
import { SizeTag } from './task/SizeTag'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const SizeOption = ({ option: size }: { option: TaskSize }): JSX.Element => {
  const { t } = useAppTranslation()

  switch (size) {
    case 'tiny':
      return (
        <React.Fragment>
          <SizeTag size={size} />
          <div className="info">
            <div className="title">
              {t('tasksList.sizeSwitcher.tiny.title')}
            </div>
            <div className="description">
              {t('tasksList.sizeSwitcher.tiny.description')}
            </div>
          </div>
        </React.Fragment>
      )
    case 'small':
      return (
        <React.Fragment>
          <SizeTag size={size} />
          <div className="info">
            <div className="title">
              {t('tasksList.sizeSwitcher.small.title')}
            </div>
            <div className="description">
              {t('tasksList.sizeSwitcher.small.description')}
            </div>
          </div>
        </React.Fragment>
      )
    case 'medium':
      return (
        <React.Fragment>
          <SizeTag size={size} />
          <div className="info">
            <div className="title">
              {t('tasksList.sizeSwitcher.medium.title')}
            </div>
            <div className="description">
              {t('tasksList.sizeSwitcher.medium.description')}
            </div>
          </div>
        </React.Fragment>
      )
    case 'large':
      return (
        <React.Fragment>
          <SizeTag size={size} />
          <div className="info">
            <div className="title">
              {t('tasksList.sizeSwitcher.large.title')}
            </div>
            <div className="description">
              {t('tasksList.sizeSwitcher.large.description')}
            </div>
          </div>
        </React.Fragment>
      )
    case 'massive':
      return (
        <React.Fragment>
          <SizeTag size={size} />
          <div className="info">
            <div className="title">
              {t('tasksList.sizeSwitcher.massive.title')}
            </div>
            <div className="description">
              {t('tasksList.sizeSwitcher.massive.description')}
            </div>
          </div>
        </React.Fragment>
      )
  }
}

const SelectedComponent = ({ value: sizes }: { value: TaskSize[] }) => {
  const { t } = useAppTranslation()

  if (sizes.length > 1) {
    return <>{t('tasksList.sizeSwitcher.multiple')}</>
  }

  switch (sizes[0]) {
    case 'tiny':
      return <>{t('tasksList.sizeSwitcher.extraSmall')}</>
    case 'small':
      return <>{t('tasksList.sizeSwitcher.small.title')}</>
    case 'medium':
      return <>{t('tasksList.sizeSwitcher.medium.title')}</>
    case 'large':
      return <>{t('tasksList.sizeSwitcher.large.title')}</>
    case 'massive':
      return <>{t('tasksList.sizeSwitcher.massive.title')}</>
    case undefined:
      return <>{t('tasksList.sizeSwitcher.allSizes')}</>
  }
}

const ResetComponent = () => {
  const { t } = useAppTranslation()

  return (
    <React.Fragment>
      <GraphicalIcon icon="task-size" className="task-icon" />
      <div className="info">
        <div className="title">{t('tasksList.sizeSwitcher.allSizes')}</div>
      </div>
    </React.Fragment>
  )
}

export const SizeSwitcher = ({
  value,
  setValue,
}: {
  value: TaskSize[]
  setValue: (sizes: TaskSize[]) => void
}): JSX.Element => {
  return (
    <MultipleSelect<TaskSize>
      options={['tiny', 'small', 'medium', 'large', 'massive']}
      value={value}
      setValue={setValue}
      label="Size"
      SelectedComponent={SelectedComponent}
      ResetComponent={ResetComponent}
      OptionComponent={SizeOption}
      className="size-switcher"
    />
  )
}
