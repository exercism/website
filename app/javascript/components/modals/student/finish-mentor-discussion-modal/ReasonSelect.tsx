import React from 'react'
import { SingleSelect } from '../../../common/SingleSelect'
import { ReportReason } from '../FinishMentorDiscussionModal'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const OptionComponent = ({ option: reason }: { option: ReportReason }) => {
  const { t } = useAppTranslation(
    'components/modals/student/finish-mentor-discussion-modal'
  )
  switch (reason) {
    case 'coc':
      return (
        <React.Fragment>
          {t('reasonSelect.codeOfConductViolation')}
        </React.Fragment>
      )
    case 'incorrect':
      return (
        <React.Fragment>
          {t('reasonSelect.wrongOrMisleadingInformation')}
        </React.Fragment>
      )
    case 'other':
      return <React.Fragment>{t('reasonSelect.other')}</React.Fragment>
  }
}

export const ReasonSelect = ({
  value,
  setValue,
}: {
  value: ReportReason
  setValue: (value: ReportReason) => void
}): JSX.Element => {
  return (
    <SingleSelect<ReportReason>
      options={['coc', 'incorrect', 'other']}
      value={value}
      setValue={setValue}
      SelectedComponent={OptionComponent}
      OptionComponent={OptionComponent}
    />
  )
}
