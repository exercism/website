type ConditionTextEntry = {
  condition: boolean
  text: string
}

export class ConditionTextManager {
  private conditions: ConditionTextEntry[]

  constructor() {
    this.conditions = []
  }

  append(condition: boolean, text: string): void {
    this.conditions.push({ condition, text })
  }

  getLastTrueText(): string | null {
    for (let i = this.conditions.length - 1; i >= 0; i--) {
      if (this.conditions[i].condition) {
        return this.conditions[i].text
      }
    }

    return null
  }
}
