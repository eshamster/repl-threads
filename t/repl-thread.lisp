(defpackage repl-threads/t/repl-thread
  (:use :cl
        :rove
        :repl-threads/repl-thread)
  (:import-from :bordeaux-threads
                :make-semaphore
                :wait-on-semaphore
                :signal-semaphore))
(in-package repl-threads/t/repl-thread)

(deftest test-repl-thread
  (let ((rt (make-repl-thread))
        (count 0)
        (sem (make-semaphore)))
    (unwind-protect
         (progn (queue-process rt (lambda ()
                                    (incf count)
                                    (signal-semaphore sem)))
                (wait-on-semaphore sem)
                (ok (= count 1)))
      (destroy-repl-thread rt))))
