import React from 'react'

type ReactButton = React.ButtonHTMLAttributes<HTMLButtonElement>

export function GoBackToExercise({ ...props }: ReactButton): JSX.Element {
  return (
    <button
      {...props}
      className="mr-16 px-[18px] py-[12px] border border-1 border-primaryBtnBorder text-primaryBtnBorder text-16 rounded-8 font-semibold shadow-xsZ1v2"
    >
      Go back to editor
    </button>
  )
}

export function ContinueButton({
  anyway,
  ...props
}: {
  anyway?: boolean
} & ReactButton): JSX.Element {
  return (
    <button {...props} className="btn-primary btn-s">
      Continue{anyway ? ' anyway' : null}
    </button>
  )
}
