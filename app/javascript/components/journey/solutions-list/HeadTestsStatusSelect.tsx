import React from 'react'
import { SingleSelect } from '@/components/common/SingleSelect'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export type HeadTestsStatus =
  | undefined
  | 'passed'
  | 'failed'
  | 'errored'
  | 'exceptioned'

const OptionComponent = ({
  option: status,
}: {
  option: HeadTestsStatus
}): JSX.Element => {
  const { t } = useAppTranslation('components/journey/solutions-list')

  switch (status) {
    case 'passed':
      return <>{t('headTestsStatusSelect.passed')}</>
    case 'failed':
      return <>{t('headTestsStatusSelect.failed')}</>
    case 'errored':
      return <>{t('headTestsStatusSelect.errored')}</>
    case 'exceptioned':
      return <>{t('headTestsStatusSelect.exceptioned')}</>
    case undefined:
      return <>{t('headTestsStatusSelect.all')}</>
  }
}

const SelectedComponent = ({ option }: { option: HeadTestsStatus }) => {
  const { t } = useAppTranslation('components/journey/solutions-list')

  switch (option) {
    case undefined:
      return <>{t('headTestsStatusSelect.latestTestsStatus')}</>
    default:
      return <OptionComponent option={option} />
  }
}

export const HeadTestsStatusSelect = ({
  value,
  setValue,
}: {
  value: HeadTestsStatus
  setValue: (value: HeadTestsStatus) => void
}): JSX.Element => {
  return (
    <SingleSelect<HeadTestsStatus>
      options={[undefined, 'passed', 'failed', 'errored', 'exceptioned']}
      value={value}
      setValue={setValue}
      SelectedComponent={SelectedComponent}
      OptionComponent={OptionComponent}
    />
  )
}
