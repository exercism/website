import React from 'react'

export function ThanksForSubmitting({
  onClick,
}: {
  onClick: () => void
}): JSX.Element {
  return (
    <>
      <h2 className="text-h2 mb-12">✨ Thanks for submitting!</h2>
      <p className="text-prose mb-24">
        If your video gets approved, it&apos;ll show up in the Approaches
        section for the exercise.
      </p>

      <div className="flex">
        <button onClick={onClick} className="w-full btn-primary btn-l grow">
          No problem. I&apos;m done here.
        </button>
      </div>
    </>
  )
}
