import React, { useState } from 'react'

export const Expander = ({
  content,
  buttonText,
  className,
}: {
  content: string
  buttonText: string
  className?: string
}): JSX.Element => {
  console.log(className)
  const [isExpanded, setIsExpanded] = useState(false)

  const classNames = [
    className,
    'c-expander',
    isExpanded ? 'expanded' : 'compressed',
  ]

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
