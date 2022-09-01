import React from 'react'

export function CancelButton({
  onClick,
}: {
  onClick: () => void
}): JSX.Element {
  return (
    <button
      onClick={onClick}
      className="mr-16 px-[18px] py-[12px] border border-1 border-primaryBtnBorder text-primaryBtnBorder text-16 rounded-8 font-semibold shadow-xsZ1v2"
    >
      Cancel
    </button>
  )
}
