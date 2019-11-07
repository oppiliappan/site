Looping constructs are bad. Consider this:

```
for (int i = 0; i < arr.len(); i++) { ... }
```

It is not obvious at all, what this loop does. Is it
supposed to iterate over the elements of the array? Is it
just a variable binding that increases up to `arr.len()`?
