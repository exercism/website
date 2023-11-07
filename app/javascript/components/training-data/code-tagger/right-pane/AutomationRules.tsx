import React from 'react'

export default function AutomationRules(): JSX.Element | null {
  return (
    <>
      <p className="text-p-base mb-12">
        These tags will be used to train neural networks to correct identify
        student's solutions. Thanks for helping out!
      </p>
      <p className="text-p-base mb-4">Here's some notes to help you:</p>
      <ul className="text-p-base list-disc ml-20">
        <li className="mb-2">
          If you are unclear on whether a tag should be added (or removed)
          please ask on <a href="https://forum.exercism.org">the forum</a>. The
          knowledge sharing helps everyone.
        </li>
        <li>
          Please try to stick to the official list of tags in the select
          dropdown. If you need to add a new tag, you can do so by typing a new
          tag, but please consider discussing it on{' '}
          <a href="https://forum.exercism.org">the forum</a>.
        </li>
      </ul>
    </>
  )
}
