#lang scheme/base

(require scheme/contract
         setup/getinfo)

; (struct string string path path string string path)
(define-struct package-info
  (name
   version
   licence-file
   copyright-holder
   copyright-year
   test-file
   test-suite)
  #:transparent)

; path -> package-info
(define (create-package-info dir)
  (let ([info-ref (get-info/full dir)])
    (make-package-info (info-ref 'name)
                       (info-ref 'version)
                       (build-path (info-ref 'licence-file))
                       (info-ref 'copyright-holder)
                       (info-ref 'copyright-year)
                       (build-path (info-ref 'test-file))
                       (info-ref 'test-suite))))

; Provide statements -----------------------------

(provide/contract
 [struct package-info ([name             string?]
                       [version          string?]
                       [licence-file     (and/c path? relative-path?)]
                       [copyright-holder string?]
                       [copyright-year   string?]
                       [test-file        (and/c path? relative-path?)]
                       [test-suite       symbol?])]
 [create-package-info (-> (and/c path? absolute-path? directory-exists?) package-info?)])