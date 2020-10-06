export class UrlParams {
  constructor(object) {
    this.object = object || {}
  }

  toString() {
    return Object.keys(this.object)
      .map((key) => {
        const value = this.object[key]

        if (Array.isArray(value)) {
          return value
            .map((item) => {
              return key + '[]=' + item
            })
            .join('&')
        } else {
          return key + '=' + value
        }
      })
      .join('&')
  }
}
