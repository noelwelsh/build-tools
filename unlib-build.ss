#lang scheme/base

(require web-server/templates
         (planet schematics/sake:1)
         "build/info.ss"
         (prefix-in action: "build/licence.ss")
         (prefix-in action: "build/stage.ss"))

; package-info
(define info
  (make-package-info (current-directory)))

; (U 'plain 'scheme) -> string
(define make-licence
  (action:licence-maker info "COPYING-template"))

; path
(define build-dir
  (build-path (current-directory) "sake-build"))

; Sake tasks -------------------------------------

(define-task compile
  ()
  (action:compile "all-tests.ss")
  (action:compile "main.ss"))

(define-task recreate-licence-file
  ()
  (action:recreate-licence-file
   (build-path (current-directory) (package-info-licence-file info))
   (make-licence 'plain)))

(define-task stage-to-build-dir
  (compile recreate-licence-file)
  (action:stage-to-build-dir build-dir)
  (action:licence-scheme-files build-dir (make-licence 'scheme)))

(define-task test
  (stage-to-build-dir)
  (action:test
   (build-path build-dir (package-info-test-file info))
   (package-info-test-suite info)))

(define-task default
  (test)
  (void))
