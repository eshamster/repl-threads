(defpackage repl-threads/repl-threads
  (:use :cl)
  (:export :make-repl-threads
           :queue-process-to
           :with-thread
           :destroy-repl-threads
           :*thread-index*)
  (:import-from :repl-threads/repl-thread
                :make-repl-thread
                :queue-process
                :destroy-repl-thread))
(in-package :repl-threads/repl-threads)

(defclass repl-threads ()
  ((threads :initarg :threads :reader rts-threads)))

(defun make-repl-threads (n)
  (let ((threads (loop :for i :from 0 :below n :collect (make-repl-thread))))
    (make-instance
     'repl-threads
     :threads (make-array n :initial-contents threads))))

(defmethod queue-process-to ((rts repl-threads) thread-index process)
  (let ((threads (rts-threads rts)))
    (assert (< thread-index (length threads)))
    (queue-process (aref threads thread-index) process)))

(defvar *thread-index* -1)

(defmacro with-thread ((rts thread-index) &body body)
  (let ((g-thread-index (gensym "THREAD-INDEX")))
    `(let ((,g-thread-index ,thread-index))
       (queue-process-to ,rts ,g-thread-index
                         (lambda ()
                           (let ((*thread-index* ,g-thread-index))
                             (declare (ignorable *thread-index*))
                             ,@body))))))

(defmethod destroy-repl-threads ((rts repl-threads))
  (let ((threads (rts-threads rts)))
    (dotimes (i (length threads))
      (destroy-repl-thread (aref threads i)))))
