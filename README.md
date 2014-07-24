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
