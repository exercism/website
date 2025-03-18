# Grades

Your trying to understand more intuitively how different classes are doing in their exams, and how different teachers are performing. You want to put together a nice chart that shows all the grades color coded, but when you get the data out of the database, you see that the grades are organised by the student's name, which makes seeing patterns harder. You've decided to sort the grades so you can put them in order and color-code them more nicely.

<img src="https://assets.exercism.org/bootcamp/graphics/grades.png" style="width: 100%; max-width:400px;margin-top:10px;margin-bottom:20px;border:1px solid #ddd;border-radius:5px"/>

In this exercise, you want to get the grades from the API, sort them, and return them along with the teacher's name.

The exercise relies heavily on your building your own library functions. I recommend starting by implementing all the functions I suggest in the section below, then thinking how you can use them to solve the exercise!

## Instructions

### Build the URL

The first part of the exercise is to turn the information you have into a URL.
For this, you need to create a `build_url(description)` function, that takes a description string, and turns it into a URL.

The string is always formatted with a class number and a year, like this: `Class 3 of 2024`.

The API you're using to retrieve the grades is formatted like this:

```
https://api.school.com/v4/grades/2025/class-6
```

You need to build the URL, inserting the correct year and class number.

You also need to set the API version.
For all results in 2024, the API used version 3 (`v3`), but in 2025, the school updated to `v4`.
The main change that affects you in this API update is that the grades you get back in `v3` were structured a string, but in `v4`, they're structured as a list of strings.

### Extract the data

The next step is to get the correct data out and format it correctly.
Create a function called `grades_to_pattern(description)`.
It will take one input - the same description as `build_url`.

To get the data you can use `fetch(url, params)` with the URL you created and an empty dictionary for the parameters.

You need to return a dictionary with the teacher's name, and the grades:

```
{"teacher":"Joseph","grades":"AAAAAA"}
```

Note that the teachers's name should just be their surname, with the initial letter(s) capitalized.

### Sort the data

Finally, you should sort the grades so that we can create our pretty charts.
Update your `grades_to_pattern` function so that the grades are in alphabetical order.
Grades will always be capital letters from A-Z.

## Library Functions

This exercise is solved most easily if you have a good library of functions read. Here are some you my like to prepare before getting too stuck in to the details here:

- [`my#split`](/bootcamp/custom_functions/split/edit)
- [`my#sort_string`](/bootcamp/custom_functions/sort_string/edit)
- [`my#capitalize`](/bootcamp/custom_functions/capitalize/edit) (which will probably use [`my#to_uppercase`](/bootcamp/custom_functions/to_uppercase/edit))
- [`my#join`](/bootcamp/custom_functions/join/edit)

## Functions

You have four functions avaible:

- `fetch(url, params)`: Fetches data from an API.
- `concatenate(str1, str2, ...)`: Takes 2 or more strings and return them combined into one.
- `push(list, elem)`. Returns a new list with the element added to the original list.
- `sort_string(string_or_list)`: Takes a string or a list and returns a string with its contents sort alphabetically.
