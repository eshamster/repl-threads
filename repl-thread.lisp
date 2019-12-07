(defpackage repl-threads/repl-thread
  (:use :cl)
  (:export :make-repl-thread
           :queue-process
           :destroy-repl-thread)
  (:import-from :repl-threads/wait-queue
                :wait-queue
                :make-wait-queue
                :queue
                :dequeue)
  (:import-from :bordeaux-threads
                :make-thread
                :destroy-thread))
(in-package :repl-threads/repl-thread)

(defclass repl-thread ()
  ((thread :initarg :thread :reader rt-thread)
   (process-queue :initarg :process-queue  :reader rt-process-queue)))

(defun make-repl-thread ()
  (let ((q (make-instance 'wait-queue)))
    (make-instance 'repl-thread
                   :thread (make-thread (make-repl-thread-process q))
                   :process-queue q)))

(defmethod make-repl-thread-process ((process-queue wait-queue))
  (lambda ()
    (loop (funcall (dequeue process-queue)))))

(defmethod queue-process ((rt repl-thread) process)
  (assert (functionp process))
  (queue (rt-process-queue rt) process)
  t)

(defmethod destroy-repl-thread ((rt repl-thread))
  (destroy-thread (rt-thread rt)))
