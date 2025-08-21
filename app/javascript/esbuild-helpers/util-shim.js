module.exports = {
  promisify:
    (fn) =>
    (...args) =>
      new Promise((resolve, reject) => {
        fn(...args, (err, result) => {
          if (err) reject(err)
          else resolve(result)
        })
      }),

  inherits: (ctor, superCtor) => {
    ctor.prototype = Object.create(superCtor.prototype)
    ctor.prototype.constructor = ctor
  },
}
