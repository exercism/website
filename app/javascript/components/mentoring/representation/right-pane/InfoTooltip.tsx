import React from 'react'

export type Tooltip = {
  body: string
  title: string
}
export default function InfoTooltip({ title, body }: Tooltip): JSX.Element {
  return (
    <div className="bg-backgroundColorB w-[460px] py-16 px-24 shadow-lgZ1 rounded-8">
      <h3 className="text-h6 mb-4">{title}</h3>
      <p className="text-[15px] leading-160">{body}</p>
    </div>
  )
}
