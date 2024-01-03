(uiop:define-package #:app/app
  (:use #:cl)
  (:import-from #:ningle)
  (:import-from #:clack)
  (:import-from #:dexador)
  (:import-from #:clack.handler.hunchentoot))
(in-package #:app/app)


(defvar *app* (make-instance 'ningle:app))

(setf (ningle:route *app* "/")
      "Welcome to ningle!")

(setf (ningle:route *app* "/login" :method :POST)
      #'(lambda (params)
          (if (authorize (cdr (assoc "username" params :test #'string=))
                         (cdr (assoc "password" params :test #'string=)))
              "Authorized!"
              "Failed...Try again.")))

(defun main ()
  (clack:clackup *app*
                 :address (or (uiop:getenv "INTERFACE")
                              "0.0.0.0")
                 :port (let ((env-port (uiop:getenv "PORT")))
                         (if env-port
                             (parse-integer env-port)
                             80))
                 :use-thread nil))
