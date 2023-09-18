import React from 'react'
import { SingleSelect } from '@/components/common/SingleSelect'

export type SyncStatus = undefined | 'up_to_date' | 'out_of_date'

const OptionComponent = ({
  option: status,
}: {
  option: SyncStatus
}): JSX.Element => {
  switch (status) {
    case 'up_to_date':
      return <>Up-to-date</>
    case 'out_of_date':
      return <>Out-of-date</>
    case undefined:
      return <>All</>
  }
}

const SelectedComponent = ({ option }: { option: SyncStatus }) => {
  switch (option) {
    case undefined:
      return <>Sync status</>
    default:
      return <OptionComponent option={option} />
  }
}

export const SyncStatusSelect = ({
  value,
  setValue,
}: {
  value: SyncStatus
  setValue: (value: SyncStatus) => void
}): JSX.Element => {
  return (
    <SingleSelect<SyncStatus>
      options={[undefined, 'up_to_date', 'out_of_date']}
      value={value}
      setValue={setValue}
      SelectedComponent={SelectedComponent}
      OptionComponent={OptionComponent}
    />
  )
}
