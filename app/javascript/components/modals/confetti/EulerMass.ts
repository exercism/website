import { Vector2D } from './Vector'

export class EulerMass {
  public position: Vector2D
  private force: Vector2D
  private velocity: Vector2D

  constructor(
    x: number,
    y: number,
    private readonly mass: number,
    private readonly drag: number
  ) {
    this.position = new Vector2D(x, y)
    this.force = new Vector2D(0, 0)
    this.velocity = new Vector2D(0, 0)
  }

  get currentForce() {
    const speed = this.velocity.length
    const dragVelocity = this.velocity.multiply(this.drag * this.mass * speed)
    return this.force.subtract(dragVelocity)
  }

  public addForce(v: Vector2D): void {
    this.force = this.force.add(v)
  }

  public integrate(dt: number): void {
    const acceleration = this.currentForce.divide(this.mass).multiply(dt)
    const deltaPosition = this.velocity.multiply(dt)
    this.position = this.position.add(deltaPosition)
    this.velocity = this.velocity.add(acceleration)
    this.force = new Vector2D(0, 0)
  }
}
