export class UrlParams {
  constructor(object) {
    this.object = object || {}
  }

  toString() {
    return Object.keys(this.object)
      .map((key) => {
        const value = this.object[key]

        // &foo=value
        if (!Array.isArray(value)) {
          return key + '=' + value
        }

        // &foo[]=value1&foo[]=value2
        return value
          .map((item) => {
            return key + '[]=' + item
          })
          .join('&')
      })
      .join('&')
  }
}
