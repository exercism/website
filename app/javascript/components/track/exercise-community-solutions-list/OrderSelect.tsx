import React from 'react'
import { SingleSelect } from '../../common/SingleSelect'
import { Order } from '../ExerciseCommunitySolutionsList'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const OptionComponent = ({ option: order }: { option: Order }) => {
  const { t } = useAppTranslation(
    'components/track/exercise-community-solutions-list'
  )
  switch (order) {
    case 'most_popular':
      return (
        <React.Fragment>{t('orderSelect.sortByMostSubmitted')}</React.Fragment>
      )
    case 'newest':
      return <React.Fragment>{t('orderSelect.sortByNewest')}</React.Fragment>
    case 'oldest':
      return <React.Fragment>{t('orderSelect.sortByOldest')}</React.Fragment>
    case 'fewest_loc':
      return (
        <React.Fragment>{t('orderSelect.sortByFewestLines')}</React.Fragment>
      )
    case 'highest_reputation':
      return (
        <React.Fragment>{t('orderSelect.sortByHighestRepUser')}</React.Fragment>
      )
  }
}

export const OrderSelect = ({
  value,
  setValue,
}: {
  value: Order
  setValue: (value: Order) => void
}): JSX.Element => {
  return (
    <SingleSelect<Order>
      options={[
        'most_popular',
        'newest',
        'oldest',
        'fewest_loc',
        'highest_reputation',
      ]}
      value={value}
      setValue={setValue}
      SelectedComponent={OptionComponent}
      OptionComponent={OptionComponent}
      className="md:w-[290px] w-100"
    />
  )
}
