import React from 'react'
export function StatePreview({
  firstTest,
}: {
  firstTest: TaskTest
  config: Config
}) {
  return (
    <p className="scenario-lhs p-8">
      The first <span className="font-semibold text-jiki-purple">scenario</span>{' '}
      is <strong>{firstTest.name}</strong>.
    </p>
  )
}
