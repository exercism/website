import React from 'react'
export function ExerciseWidget({
  exercise,
}: {
  exercise: Record<'exerciseUrl' | 'iconUrl' | 'title', string>
}) {
  return (
    <span className="inline-flex">
      &nbsp;
      <a
        href={exercise.exerciseUrl}
        className="flex flex-row items-center font-semibold text-prominentLinkColor"
      >
        <img src={exercise.iconUrl} className="w-[24px] h-[24px] mr-8" />
        {exercise.title}
      </a>
    </span>
  )
}
