import React from 'react'
import { ExerciseDifficulty } from '../../types'

export const Difficulty = ({
  difficulty,
}: {
  difficulty: ExerciseDifficulty
}): JSX.Element => {
  switch (difficulty) {
    case 'easy':
      return <div className="--difficulty --easy">Easy</div>
  }
}
