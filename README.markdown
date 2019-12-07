[![Build Status](https://travis-ci.com/eshamster/repl-threads.svg?branch=master)](https://travis-ci.com/eshamster/repl-threads)

# repl-threads - a library to try thread on REPL

## Example

(`rts` is nickname of `repl-threads` and `bt` is nickname of [bordeaux-threads](https://common-lisp.net/project/bordeaux-threads/))

```lisp
;; Start 2 threads
CL-USER> (defparameter *rts* (rts:make-repl-threads 2))
*RTS*
CL-USER> (defparameter *lock* (bt:make-lock))
*LOCK*
;; Execute in thread 0
CL-USER> (rts:with-thread (*rts* 0)
           (bt:acquire-lock *lock*)
           (print :thread0))
T
:THREAD0
;; Execute in thread 1
;; This will be waited until the *lock* is released.
CL-USER> (rts:with-thread (*rts* 1)
           (bt:acquire-lock *lock*)
           (print :thread1)         ; This will be waited.
           (bt:release-lock *lock*))
T
CL-USER> (rts:with-thread (*rts* 0)
           (bt:release-lock *lock*))
T
:THREAD1 ; The output is from thread 1.
;; Destroy threads.
CL-USER> (rts:destroy-repl-methods *rts*)
NIL
```

## Installation

This project is not registered to the Quicklisp repository. So you need to clone this project to a directory where `ql:quickload` can detect. If you are a [Roswell](https://github.com/roswell/roswell/) user, the following is easy.

```sh
$ ros install eshamster/repl-threads
```

## Author

* eshamster (hamgoostar@gmail.com)

## Copyright

Copyright (c) 2019 eshamster (hamgoostar@gmail.com)

## License

Licensed under the LLGPL License.
