export class Vector2D {
  constructor(public x: number, public y: number) {}

  /**
   * Static methods
   */

  static distance(v0: Vector2D, v1: Vector2D) {
    return Math.sqrt(Vector2D.squareDistance(v0, v1))
  }

  static squareDistance(v0: Vector2D, v1: Vector2D) {
    const x = v0.x - v1.x
    const y = v0.y - v1.y
    return x * x + y * y
  }

  static sub(v0: Vector2D, v1: Vector2D) {
    return new Vector2D(v0.x - v1.x, v0.y - v1.y)
  }

  public get length(): number {
    return Math.sqrt(this.squareLength)
  }

  public get squareLength(): number {
    return this.x * this.x + this.y * this.y
  }

  public clone(): Vector2D {
    return new Vector2D(this.x, this.y)
  }

  public add(vector: Vector2D): Vector2D {
    return new Vector2D(this.x + vector.x, this.y + vector.y)
  }

  public subtract(vector: Vector2D): Vector2D {
    return new Vector2D(this.x - vector.x, this.y - vector.y)
  }

  public multiply(factor: number): Vector2D {
    return new Vector2D(this.x * factor, this.y * factor)
  }

  public divide(factor: number): Vector2D {
    return new Vector2D(this.x / factor, this.y / factor)
  }

  public normalize(): Vector2D {
    if (this.squareLength === 0) {
      return this.clone()
    }

    const factor = 1.0 / Math.sqrt(this.squareLength)
    return this.multiply(factor)
  }
}
