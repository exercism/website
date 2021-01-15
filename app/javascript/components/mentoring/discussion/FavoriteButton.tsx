import React, { useState } from 'react'
import { AddFavoriteButton } from './AddFavoriteButton'
import { RemoveFavoriteButton } from './RemoveFavoriteButton'

export const FavoriteButton = ({
  endpoint,
  ...props
}: {
  isFavorite: boolean
  endpoint: string
}): JSX.Element | null => {
  const [isFavorite, setIsFavorite] = useState(props.isFavorite)
  const [isHovering, setIsHovering] = useState(false)

  if (!isFavorite) {
    return (
      <AddFavoriteButton
        endpoint={endpoint}
        onSuccess={() => setIsFavorite(true)}
      />
    )
  }

  if (isHovering) {
    return (
      <RemoveFavoriteButton
        endpoint={endpoint}
        onMouseLeave={() => setIsHovering(false)}
        onSuccess={() => setIsFavorite(false)}
      />
    )
  }

  return <div onMouseEnter={() => setIsHovering(true)}>Favorited</div>
}
