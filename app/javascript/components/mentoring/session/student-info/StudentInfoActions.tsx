import React from 'react'
import { Student } from '@/components/types'
import { FavoriteButton, FavoritableStudent } from '../FavoriteButton'

export function StudentInfoActions({
  student,
  setStudent,
}: {
  student: Student
  setStudent: (student: Student) => void
}) {
  return (
    <React.Fragment>
      {student.links.favorite ? (
        <FavoriteButton
          student={student as FavoritableStudent}
          onSuccess={(student) => setStudent(student)}
        />
      ) : null}
    </React.Fragment>
  )
}
