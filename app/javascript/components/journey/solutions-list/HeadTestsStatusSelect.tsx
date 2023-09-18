import React from 'react'
import { SingleSelect } from '@/components/common/SingleSelect'

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

const SelectedComponent = ({ option }: { option: HeadTestsStatus }) => {
  switch (option) {
    case undefined:
      return <>Latest Tests status</>
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
