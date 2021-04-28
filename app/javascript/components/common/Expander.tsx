import React, { useState } from 'react'

export const Expander = ({
  content,
  buttonText,
}: {
  content: string
  buttonText: string
}): JSX.Element => {
  const [isExpanded, setIsExpanded] = useState(false)

  const classNames = ['c-expander', isExpanded ? 'expanded' : 'compressed']

  return (
    <div className={classNames.join(' ')}>
      <div className="content" dangerouslySetInnerHTML={{ __html: content }} />
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
