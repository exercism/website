import React from 'react'
export function ExerciseWidget({
  exercise,
}: {
  exercise: Record<'exerciseUrl' | 'iconUrl' | 'title', string>
}) {
  return (
    <span className="inline-flex">
      <a
        href={exercise.exerciseUrl}
        className="flex flex-row items-center font-semibold text-prominentLinkColor"
      >
        {exercise.title}
      </a>
      .
    </span>
  )
}
