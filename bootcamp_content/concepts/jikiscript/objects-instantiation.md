# Creating Objects

## Classes

When we want to create new objects, we use a blueprint.
The formal name for a blueprint is a "Class".

Classes specify the different data and functionality that objects created using that blueprint will have.

Classes are written using "Pascal Case", which means thapp/models/course_enrollment.rb:ey always start with a capital letter, and word divisions use another capital letter, rather than underscores.

<img src="https://assets.exercism.org/bootcamp/diagrams/objects-classes.png" class="diagram"/>

## The new keyword

When we want to create an object, we use the `new` keyword, along with the class name, to tell Jiki which blueprint we want to use.

<img src="https://assets.exercism.org/bootcamp/diagrams/objects-new-1.png" class="diagram"/>

We can also specify certain values when we create the object.
We can only provide values that the blueprint expects.

To do this, we use a syntax very similar to when we call a function, using parentheses with comma-separated inputs.

<img src="https://assets.exercism.org/bootcamp/diagrams/objects-new-2.png" class="diagram"/>

There are two fundamental ideas in programming:

1. Having information (data) that you read, change and use.
2. Having some sort of functionality that actually does stuff.

Objects bring these two ideas together into one, allowing you to encapsulate the data and functionality that something might need into... object.

## New Shelves

Jiki has two new sets of shelves - one for the classes (blueprints), and one for the objects you make.
Any time you make a new object (even if you make it inside a function), Jiki always puts it this one set of object shelves.

<img src="https://assets.exercism.org/bootcamp/diagrams/objects-shelves.png" class="diagram"/>

## An example

### Creating the object

Let's see what happens when we ask Jiki to create a Person.

Firstly he goes and gets the Blueprint from the shelves, and makes an Object based on the information we've given him.

<img src="https://assets.exercism.org/bootcamp/diagrams/objects-new-3.png" class="diagram"/>

He uses the name and age we provide and puts them into boxes inside the object. (Note, he's only doing that because the blueprint tells him to. It could tell him to do other things with that data instead!).

Then he shrinks the object down.

<img src="https://assets.exercism.org/bootcamp/diagrams/objects-new-4.png" class="diagram"/>

He now writes a **unique tag** for that object.
It's value isn't important (in fact, we'll never know it) but what matters is that every object has a unique tag, and Jiki can use that tag to find specific objects later.

Once the tag is securely attached, he puts the object on the shelves.

<img src="https://assets.exercism.org/bootcamp/diagrams/objects-new-5.png" class="diagram"/>

### Storing a reference to the object

Now we've created the object and put it on the shelves, we need to store a reference to it, so that we can use it again later.

To do this, Jiki creates a **copy of the tag**, and puts that copy into the box.

<img src="https://assets.exercism.org/bootcamp/diagrams/objects-new-6.png" class="diagram"/>

Now, whenever we ask him to use that variable (box) in the future, he'll be able to retrieve the tag, then compare it to the objects on the shelves to find the right one.
