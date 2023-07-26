import React from 'react'
export function Choices({
  context,
  children,
}: {
  context: { choices: string[] }
  children: React.ReactChild
}): JSX.Element {
  return (
    <>
      <div className="flex gap-8 mb-8">
        {context.choices.map((choice, key) => (
          <span
            className="py-6 px-12 bg-textColor6NoDark text-aliceBlue rounded-24"
            key={key}
          >
            {choice}
          </span>
        ))}
      </div>
      {children}
    </>
  )
}
