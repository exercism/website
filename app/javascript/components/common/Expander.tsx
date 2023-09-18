import React, { useState } from 'react'

export default function Expander({
  content,
  buttonTextCompressed,
  buttonTextExpanded,
  className,
  contentIsSafe,
}: {
  content: string
  buttonTextCompressed: string
  buttonTextExpanded: string
  className?: string
  contentIsSafe: boolean
}): JSX.Element {
  const [isExpanded, setIsExpanded] = useState(false)

  const classNames = [
    className,
    'c-expander',
    isExpanded ? 'expanded' : 'compressed',
  ]

  const buttonText = isExpanded ? buttonTextExpanded : buttonTextCompressed

  return (
    <div className={classNames.join(' ')}>
      {contentIsSafe ? (
        <div
          className="content"
          dangerouslySetInnerHTML={{ __html: content }}
        />
      ) : (
        <div className="content">{content}</div>
      )}
      <button
        type="button"
        onClick={() => {
          setIsExpanded(!isExpanded)
        }}
      >
        {buttonText}
      </button>
    </div>
  )
}
