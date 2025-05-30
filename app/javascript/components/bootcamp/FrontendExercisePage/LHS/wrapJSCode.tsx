import { scriptPrelude, scriptPostlude } from '../utils/updateIFrame'

export function wrapJSCode(jsCode: string, jsCodeRunId: number) {
  return `<script>
window.__runId__ = ${jsCodeRunId};
${scriptPrelude} ${jsCode || ''} ${scriptPostlude}
//# sourceURL=exercise.js
</script>`
}
