import { scriptPrelude, scriptPostlude } from '../utils/updateIFrame'

export function wrapJSCode(jsCode: string) {
  return `<script>
${scriptPrelude}${jsCode || ''}${scriptPostlude}
</script>`
}
