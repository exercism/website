import React, { useState } from 'react'
import { AddFavoriteButton } from './favorite-button/AddFavoriteButton'
import { RemoveFavoriteButton } from './favorite-button/RemoveFavoriteButton'
import { Student } from '../../types'

export type FavoritableStudent = Student & { links: { favorite: string } }

export const FavoriteButton = ({
  student,
  onSuccess,
}: {
  student: FavoritableStudent
  onSuccess: (student: FavoritableStudent) => void
}): JSX.Element | null => {
  const [isRemoveButtonHoverable, setIsRemoveButtonHoverable] = useState(true)
  return (
    <div className="button-wrapper">
      {student.isFavorited ? (
        <RemoveFavoriteButton
          endpoint={student.links.favorite}
          onSuccess={(student) => onSuccess(student)}
          isRemoveButtonHoverable={isRemoveButtonHoverable}
          setIsRemoveButtonHoverable={setIsRemoveButtonHoverable}
        />
      ) : (
        <AddFavoriteButton
          endpoint={student.links.favorite}
          onSuccess={(student) => onSuccess(student)}
          setIsRemoveButtonHoverable={setIsRemoveButtonHoverable}
        />
      )}
    </div>
  )
}
