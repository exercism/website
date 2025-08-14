import React, { useCallback, useState } from 'react'
import { ManageCustomFunctionsModal } from './ManageCustomFunctionsModal'
import { Icon } from '@/components/common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function CustomFunctionsButton({ onChange }: { onChange?: () => void }) {
  const [isManagerModalOpen, setIsManagerModalOpen] = useState(false)
  const { t } = useAppTranslation(
    'components/bootcamp/CustomFunctionEditor/Header'
  )

  const setManagerModalOpen = useCallback(() => {
    setIsManagerModalOpen(true)
  }, [])

  return (
    <>
      <button onClick={setManagerModalOpen} className="btn-secondary btn-xxs">
        <Icon
          icon="bootcamp-custom-functions"
          alt={t('customFunctionsButton.dependencies')}
          className="filter-purple w-[12px] h-[12px]"
        />
        <span>{t('customFunctionsButton.dependencies')}</span>
      </button>

      <ManageCustomFunctionsModal
        isOpen={isManagerModalOpen}
        setIsOpen={setIsManagerModalOpen}
        onChange={onChange}
      />
    </>
  )
}
