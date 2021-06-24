import React from 'react'
import { ExerciseDifficulty, Size } from '../../types'

export const Difficulty = ({
  difficulty,
  size,
}: {
  difficulty: ExerciseDifficulty
  size?: Size
}): JSX.Element => {
  const sizeClassName = size ? `--${size}` : ''

  switch (difficulty) {
    case 'easy':
      return (
        <div className={`c-difficulty-tag --easy ${sizeClassName}`}>
          <div className="icon"></div>Easy
        </div>
      )
    case 'medium':
      return (
        <div className={`c-difficulty-tag --medium ${sizeClassName}`}>
          <div className="icon"></div>Medium
        </div>
      )
    case 'hard':
      return (
        <div className={`c-difficulty-tag --hard ${sizeClassName}`}>
          <div className="icon"></div>Hard
        </div>
      )
  }
}
