import React from 'react'
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
  return (
    <div className="button-wrapper">
      {student.isFavorited ? (
        <RemoveFavoriteButton
          endpoint={student.links.favorite}
          onSuccess={(student) => onSuccess(student)}
        />
      ) : (
        <AddFavoriteButton
          endpoint={student.links.favorite}
          onSuccess={(student) => onSuccess(student)}
        />
      )}
    </div>
  )
}
