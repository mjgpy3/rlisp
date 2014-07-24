rlisp
=====

Probably the worst gem/DSL/idea for ruby ever. A lisp-like language as a DSL! Very WIP.

Here's a code example!
```
require 'rlisp'

Rlisp do
  [
    [:defn, :div_by, [:a, :b], [:eql, 0, [:mod, :a, :b]]],
    [:defn,:fizz_buzz, [:a],
      [:if, [:div_by, :a, 15],
        'FizzBuzz',
        [:if, [:div_by, :a, 3],
          'Fizz',
          [:if, [:div_by, :a, 5],
            'Buzz',
            :a
          ]
        ]
      ]
    ],
    [:print, [:map, :fizz_buzz, [:range, 1, 101]]]
  ]
end
```

## What can it do?
 - The operators you might expect
 - Quotes, for delaying execution
 - `defn` for defining functions
 - `map` and `filter`
 - `range` for generating a range of numbers
 - Standard equality checkers `eq` and `eql` (not confusing at all)
 - A ruby fallback, so if your ruby method is defined somewhere, it may just work!
 - a print function (really just ruby's `puts`, shhhh)
 - An `if` conditional, so you can work that logical magic

See `./spec/lib/rlisp_spec.rb` for proven, working examples!
