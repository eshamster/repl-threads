(defpackage repl-threads/wait-queue
  (:use :cl)
  (:export :wait-queue
           :make-wait-queue
           :queue
           :dequeue)
  (:import-from :repl-threads/queue
                :make-queue
                :queue
                :dequeue
                :queue-length)
  (:import-from :bordeaux-threads
                :make-lock
                :with-lock-held
                :make-condition-variable
                :condition-notify
                :condition-wait))
(in-package :repl-threads/wait-queue)

(defclass wait-queue ()
  ((queue :initform (make-queue) :reader wq-queue)
   (cond-var :initform (make-condition-variable :name "WAIT QUEUE COND") :reader wq-cond-var)
   (wait-count :initform 0 :accessor wq-wait-count)
   (lock :initform (make-lock "WAIT QUEUE LOCK") :reader wq-lock)))

(defun make-wait-queue ()
  (make-instance 'wait-queue))

(defmethod queue ((wq wait-queue) value)
  (let ((q (wq-queue wq)))
    (with-lock-held ((wq-lock wq))
      (queue q value)
      (when (> (wq-wait-count wq) 0)
        (decf (wq-wait-count wq))
        (condition-notify (wq-cond-var wq))))))

(defmethod dequeue ((wq wait-queue))
  (let ((lock (wq-lock wq))
        (q (wq-queue wq)))
    (with-lock-held (lock)
      (when (= (queue-length q) 0)
        (incf (wq-wait-count wq))
        ;; wait until some value is queued
        (condition-wait (wq-cond-var wq) lock))
      (assert (> (queue-length q) 0))
      (dequeue q))))
