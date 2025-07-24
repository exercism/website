import React from 'react'
import { SingleSelect } from '../../common/SingleSelect'
import { Order } from '../TestimonialsList'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const OptionComponent = ({ option: order }: { option: Order }) => {
  const { t } = useAppTranslation('components/mentoring/testimonials-list')

  switch (order) {
    case 'unrevealed':
      return (
        <React.Fragment>
          {t('orderSelect.sortByUnrevealedFirst')}
        </React.Fragment>
      )
    case 'newest':
      return (
        <React.Fragment>{t('orderSelect.sortByNewestFirst')}</React.Fragment>
      )
    case 'oldest':
      return (
        <React.Fragment>{t('orderSelect.sortByOldestFirst')}</React.Fragment>
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
      options={['unrevealed', 'newest', 'oldest']}
      value={value}
      setValue={setValue}
      SelectedComponent={OptionComponent}
      OptionComponent={OptionComponent}
    />
  )
}
