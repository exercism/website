import React from 'react'

export function Flag({
  countryCode,
}: {
  countryCode?: string
}): JSX.Element | null {
  return (
    <span
      className={`fi fi-${countryCode} shadow-smZ1 h-[24px] w-[32px] mr-12 flex-shrink-0 rounded-3 mt-6`}
    />
  )
}
