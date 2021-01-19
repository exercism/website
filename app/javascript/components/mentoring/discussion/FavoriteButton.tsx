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

  return (
    <div className="button-wrapper">
      {isFavorite ? (
        <RemoveFavoriteButton
          endpoint={endpoint}
          onSuccess={() => setIsFavorite(false)}
        />
      ) : (
        <AddFavoriteButton
          endpoint={endpoint}
          onSuccess={() => setIsFavorite(true)}
        />
      )}
    </div>
  )
}
