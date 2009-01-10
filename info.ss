#lang scheme/base

(require "info-internal.ss")

; Provide statements -----------------------------

(provide (except-out (all-from-out "info-internal.ss")
                     make-package-info)
         (rename-out [create-package-info make-package-info]))
