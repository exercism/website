import React from 'react'

export const InstructionsPanel = ({
  introduction,
  instructions,
  exampleSolution,
}: {
  introduction: string
  instructions: string
  exampleSolution: string
}) => (
  <section className="instructions">
    <div className="c-textual-content">
      <h2>Introduction</h2>
      <div dangerouslySetInnerHTML={{ __html: introduction }} />

      <h2>Instructions</h2>
      <div dangerouslySetInnerHTML={{ __html: instructions }} />

      <h3 className="text-h3 tw-mt-20">Example solution</h3>
      <pre dangerouslySetInnerHTML={{ __html: exampleSolution }} />
    </div>
  </section>
)
