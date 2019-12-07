(defpackage repl-threads/t/repl-threads
  (:use :cl
        :rove
        :repl-threads/repl-threads)
  (:import-from :bordeaux-threads
                :make-semaphore
                :wait-on-semaphore
                :signal-semaphore
                :make-lock
                :with-lock-held))
(in-package repl-threads/t/repl-threads)

(defun test-thread-index (expect)
  (= *thread-index* expect))

(deftest test-repl-threads
  (let ((rts (make-repl-threads 2))
        (count 0)
        (sem (make-semaphore))
        (lock (make-lock)))
    (unwind-protect
         (progn (with-thread (rts 0)
                  (with-lock-held (lock)
                    (ok (= *thread-index* 0)))
                  (with-lock-held (lock)
                    (ok (test-thread-index 0)))
                  (with-lock-held (lock)
                    (incf count))
                  (signal-semaphore sem))
                (with-thread (rts 1)
                  (with-lock-held (lock)
                    (ok (= *thread-index* 1)))
                  (with-lock-held (lock)
                    (ok (test-thread-index 1)))
                  (with-lock-held (lock)
                    (incf count))
                  (signal-semaphore sem))
                (wait-on-semaphore sem)
                (wait-on-semaphore sem)
                (ok (= count 2)))
      (destroy-repl-threads rts))))
