#|
  This file is a part of repl-threads project.
  Copyright (c) 2019 eshamster (hamgoostar@gmail.com)
|#

(defsystem repl-threads
  :version "0.1"
  :class :package-inferred-system
  :author "eshamster"
  :license "LLGPL"
  :depends-on (:repl-threads/main
               :bordeaux-threads)
  :description "repl-threads is a library to try thread on REPL"
  :in-order-to ((test-op (test-op repl-threads/t))))

(defsystem repl-threads/t
  :class :package-inferred-system
  :depends-on (:rove
               "repl-threads/t/queue"
               "repl-threads/t/wait-queue"
               "repl-threads/t/repl-thread"
               "repl-threads/t/repl-threads")
  :perform (test-op (o c) (symbol-call :rove '#:run c)))
