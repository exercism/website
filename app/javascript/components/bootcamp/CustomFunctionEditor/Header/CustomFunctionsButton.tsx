import React, { useCallback, useState } from 'react'
import { ManageCustomFunctionsModal } from './ManageCustomFunctionsModal'
import { Icon } from '@/components/common'

export function CustomFunctionsButton({ onChange }: { onChange?: () => void }) {
  const [isManagerModalOpen, setIsManagerModalOpen] = useState(false)

  const setManagerModalOpen = useCallback(() => {
    setIsManagerModalOpen(true)
  }, [])

  return (
    <>
      <button onClick={setManagerModalOpen} className="btn-secondary btn-xxs">
        <Icon
          icon="bootcamp-custom-functions"
          alt="Custom Functions"
          className="filter-purple w-[12px] h-[12px]"
        />
        <span>Dependencies</span>
      </button>

      <ManageCustomFunctionsModal
        isOpen={isManagerModalOpen}
        setIsOpen={setIsManagerModalOpen}
        onChange={onChange}
      />
    </>
  )
}
