(defpackage repl-threads/t/wait-queue
  (:use :cl
        :rove
        :repl-threads/wait-queue)
  (:import-from :bordeaux-threads
                :make-thread
                :destroy-thread
                :make-semaphore
                :wait-on-semaphore
                :signal-semaphore))
(in-package repl-threads/t/wait-queue)

(defun make-test-thread (timeout-sec sem func)
  (let ((th (make-thread
             (lambda ()
               (unwind-protect
                    (funcall func)
                 (signal-semaphore sem))))))
    (make-thread (lambda ()
                   (sleep timeout-sec)
                   (ignore-errors
                     (destroy-thread th))))))

(defun make-sems (n)
  (loop :for x :from 0 :below n :collect (make-semaphore)))

(defun wait-sems (sems)
  (dolist (sem sems)
    (wait-on-semaphore sem)))

(deftest test-wait-queue
  (let ((wq (make-wait-queue))
        (sems (make-sems 2))
        (count 0))
    (make-test-thread 0.1 (nth 0 sems)
                      (lambda ()
                        (queue wq 0)
                        (queue wq 1)))
    (make-test-thread 0.1 (nth 1 sems)
                      (lambda ()
                        (ok (= (dequeue wq) 0))
                        (incf count)
                        (ok (= (dequeue wq) 1))
                        (incf count)
                        (dequeue wq)
                        (incf count) ; never reach
                        ))
    (wait-sems sems)
    (ok (= count 2))))
