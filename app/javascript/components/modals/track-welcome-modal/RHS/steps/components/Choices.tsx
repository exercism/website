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
      <div className="flex gap-8 ">
        {context.choices.map((choice, key) => (
          <span
            className="px-2 py-12 bg-textColor6NoDark text-aliceBlue rounded-8"
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
