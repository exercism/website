import React from 'react'

type NoContentYetProps = {
  exerciseTitle: string
  contentType: string
  children: React.ReactNode
}
export function NoContentYet({
  exerciseTitle,
  contentType,
  children,
}: NoContentYetProps): JSX.Element {
  return (
    <div className="text-textColor6 flex flex-col items-left bg-backgroundColorB rounded-8">
      <div className="text-label-timestamp text-16 mb-4 font-semibold">
        There are no {contentType} for {exerciseTitle}.
      </div>
      <div className="flex md:flex-row flex-col text-15 leading-150">
        {children}
      </div>
    </div>
  )
}
