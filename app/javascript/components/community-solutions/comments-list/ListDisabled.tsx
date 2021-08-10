import React from 'react'

export const ListDisabled = ({
  isAuthor,
}: {
  isAuthor: boolean
}): JSX.Element => {
  if (isAuthor) {
    return <p>You have comments disabled</p>
  } else {
    return <p>Comments have been disabled</p>
  }
}
