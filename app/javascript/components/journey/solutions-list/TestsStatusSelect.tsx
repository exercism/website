import React from 'react'
import { SingleSelect } from '@/components/common/SingleSelect'

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
  switch (status) {
    case 'passed':
      return <>Passed</>
    case 'failed':
      return <>Failed</>
    case 'errored':
      return <>Errored</>
    case 'exceptioned':
      return <>Exceptioned</>
    case undefined:
      return <>All</>
  }
}

const SelectedComponent = ({ option }: { option: TestsStatus }) => {
  switch (option) {
    case undefined:
      return <>Tests status</>
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
