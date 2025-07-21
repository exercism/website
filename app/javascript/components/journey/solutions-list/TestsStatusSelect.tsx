import React from 'react'
import { SingleSelect } from '@/components/common/SingleSelect'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export type TestsStatus =
  | undefined
  | 'passed'
  | 'failed'
  | 'errored'
  | 'exceptioned'

const OptionComponent = ({
  option: status,
}: {
  option: TestsStatus
}): JSX.Element => {
  const { t } = useAppTranslation('components/journey/solutions-list')

  switch (status) {
    case 'passed':
      return <>{t('testsStatusSelect.passed')}</>
    case 'failed':
      return <>{t('testsStatusSelect.failed')}</>
    case 'errored':
      return <>{t('testsStatusSelect.errored')}</>
    case 'exceptioned':
      return <>{t('testsStatusSelect.exceptioned')}</>
    case undefined:
      return <>{t('testsStatusSelect.all')}</>
  }
}

const SelectedComponent = ({ option }: { option: TestsStatus }) => {
  const { t } = useAppTranslation('components/journey/solutions-list')

  switch (option) {
    case undefined:
      return <>{t('testsStatusSelect.testsStatus')}</>
    default:
      return <OptionComponent option={option} />
  }
}

export const TestsStatusSelect = ({
  value,
  setValue,
}: {
  value: TestsStatus
  setValue: (value: TestsStatus) => void
}): JSX.Element => {
  return (
    <SingleSelect<TestsStatus>
      options={[undefined, 'passed', 'failed', 'errored', 'exceptioned']}
      value={value}
      setValue={setValue}
      SelectedComponent={SelectedComponent}
      OptionComponent={OptionComponent}
    />
  )
}
