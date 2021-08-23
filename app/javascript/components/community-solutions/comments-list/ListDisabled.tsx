import React from 'react'

export const ListDisabled = ({
  isAuthor,
}: {
  isAuthor: boolean
}): JSX.Element => {
  if (isAuthor) {
    return (
      <p className="text-16 leading-150 text-textColor6">
        You have disabled comments on this solution. Use the "Options" cog above
        to toggle this option.
      </p>
    )
  } else {
    return <p>Comments have been disabled</p>
  }
}
