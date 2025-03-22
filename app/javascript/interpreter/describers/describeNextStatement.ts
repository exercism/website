import { Description, DescriptionContext, FrameWithResult } from '../frames'

export function describeContinueStatement(
  _fr: FrameWithResult,
  _dc: DescriptionContext
): Description {
  const result = `<p>This line stopped running any more code in this iteration.</p>`
  const steps = [
    `<li>Jiki saw this and decided to move on to the next iteration.</li>`,
  ]
  return { result, steps }
}
