// i18n-key-prefix: iterationSelect
// i18n-namespace: components/modals/student
import React from 'react'
import { SingleSelect } from '../../common/SingleSelect'
import { Iteration } from '../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const OptionComponent = ({ option: idx }: { option: number }) => {
  const { t } = useAppTranslation('components/modals/student')
  return (
    <React.Fragment>{t('iterationSelect.iteration', { idx })}</React.Fragment>
  )
}

export const IterationSelect = ({
  iterations,
  value,
  setValue,
}: {
  iterations: readonly Iteration[]
  value: number | null
  setValue: (value: number) => void
}): JSX.Element => {
  return (
    <SingleSelect<number>
      options={iterations.map((i) => i.idx)}
      value={value || iterations[0].idx}
      setValue={setValue}
      SelectedComponent={OptionComponent}
      OptionComponent={OptionComponent}
    />
  )
}
