import React from 'react'
export function IOPreview({ firstTest }: { firstTest: TaskTest }) {
  return (
    <div className="scenario-lhs">
      <p>
        The first{' '}
        <span className="font-semibold text-jiki-purple">scenario</span> is{' '}
        <strong>{firstTest.name}</strong>.
      </p>
      <p>
        We'll run{' '}
        <code className="prominent">
          {firstTest.function}({firstTest.params.join(', ')})
        </code>{' '}
        and expect it to <code className="text-[#a626a4]">return</code>{' '}
        <code className="prominent">{firstTest.expected}</code>
      </p>
    </div>
  )
}
