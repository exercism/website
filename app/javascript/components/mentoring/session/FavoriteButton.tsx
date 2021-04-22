import React from 'react'
import { AddFavoriteButton } from './AddFavoriteButton'
import { RemoveFavoriteButton } from '../session/RemoveFavoriteButton'
import { Student } from '../Session'

export const FavoriteButton = ({
  student,
  onSuccess,
}: {
  student: Student
  onSuccess: (student: Student) => void
}): JSX.Element | null => {
  return (
    <div className="button-wrapper">
      {student.isFavorite ? (
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
