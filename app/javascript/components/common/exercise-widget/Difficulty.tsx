import React from 'react'
import { ExerciseDifficulty, Size } from '../../types'

export const Difficulty = ({
  difficulty,
  size,
}: {
  difficulty: ExerciseDifficulty
  size: Size
}): JSX.Element => {
  switch (difficulty) {
    case 'easy':
      return (
        <div className={`c-difficulty-tag --${size} --easy`}>
          <div className="icon"></div>Easy
        </div>
      )
  }
}
