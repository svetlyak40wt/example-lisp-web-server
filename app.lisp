(uiop:define-package #:app/app
  (:use #:cl)
  (:import-from #:log)
  (:import-from #:ningle
                #:*response*
                #:*request*)
  (:import-from #:clack)
  (:import-from #:dexador)
  (:import-from #:clack.handler.hunchentoot)
  (:import-from #:alexandria
                #:appendf
                #:assoc-value)
  (:import-from #:babel
                #:octets-to-string)
  (:import-from #:lack.request
                #:request-content)
  (:import-from #:lack.response
                #:response-headers)
  (:import-from #:lack.response
                #:response-headers)
  (:import-from #:lack.request
                #:request-headers))
(in-package #:app/app)


(defvar *app* (make-instance 'ningle:app))


(setf (ningle:route *app* "/")
      "Hello from LISP microservice!")


(setf (ningle:route *app* "/" :method :POST)
      (lambda (params)
        (declare (ignore params))
        
        (let* ((input (octets-to-string
                       ;; Here we are reading whole HTTP POST body
                       ;; as an input:
                       (request-content *request*)
                       :encoding :utf-8))
               ;; And optionally read the URL for handshake from HTTP header X-Handshake-URL
               (handshake-url (gethash "x-handshake-url"
                                       (request-headers *request*)))
               (handshake-content
                 (concatenate 'string
                              input
                              " Hello from LISP microservice!")))
          (appendf (response-headers *response*)
                   (list :content-type "text/plain"))

          (cond
            (handshake-url
             (let* ((response
                      (handler-case
                          (dex:post handshake-url
                                    :content handshake-content)
                        (error (e)
                          (setf (lack.response:response-status *response*) 500)
                          (format nil "Some error has happened when we tried to POST to \"~A\":~%~A"
                                  handshake-url
                                  e)))))
               response))
            (t
             ;; No X-Handshake-URL header was specified so we don't call the next
             ;; server and just return result as is.
             handshake-content)))))


(defun main (&key interface port use-thread (debug t))
  (clack:clackup *app*
                 :address (or interface
                              (uiop:getenv "INTERFACE")
                              "0.0.0.0")
                 :port (or port
                           (let ((env-port (uiop:getenv "PORT")))
                             (if env-port
                                 (parse-integer env-port)
                                 80)))
                 :debug debug
                 :use-thread use-thread))
