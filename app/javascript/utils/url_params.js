export class UrlParams {
  constructor(object) {
    this.object = object
  }

  toString() {
    return Object.keys(this.object)
      .map((key) => key + '=' + this.object[key])
      .join('&')
  }
}
