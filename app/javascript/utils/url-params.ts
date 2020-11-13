type Param = string | number | boolean
type Params = Record<string, Param | Param[]>

export class UrlParams {
  private readonly params: Params

  constructor(params: Params | undefined | null) {
    this.params = params || {}
  }

  toString() {
    return Object.keys(this.params)
      .map((key) => {
        const value = this.params[key]

        // &foo=value
        if (!Array.isArray(value)) {
          return `${key}=${encodeURIComponent(value)}`
        }

        // &foo[]=value1&foo[]=value2
        return value
          .map((item) => {
            return `${key}[]=${encodeURIComponent(item)}`
          })
          .join('&')
      })
      .join('&')
  }
}
