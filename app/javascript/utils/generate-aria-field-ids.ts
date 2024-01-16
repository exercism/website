import { generateHexString } from './generate-hex-string'

export function generateAriaFieldIds(componentName: string): {
  labelledby: string
  describedby: string
} {
  return {
    labelledby: `aria-${generateHexString(5)}-${componentName}-label`,
    describedby: `aria-${generateHexString(5)}-${componentName}-description`,
  }
}
