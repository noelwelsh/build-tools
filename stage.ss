#lang scheme/base

(require scheme/contract
         scheme/file
         setup/getinfo
         (planet schematics/sake:1)
         (planet untyped/unlib:3/debug)
         (planet untyped/unlib:3/file)
         "licence.ss")

; NOTE: In the comments below, items between asterisks refer to keys in info.ss.

; symbol -> any
; (define info-ref (get-info/full (current-directory)))

; path -> void
;
; Creates a directory called "sake-build" and copies
; the contents of the current directory in there.
(define (stage-to-build-dir build-dir)
  ; recreate the build directory:
  (when (directory-exists? build-dir)
    (delete-directory/files build-dir))
  (make-directory build-dir)
  
  ; copy everything into the build directory:
  (for ([src-item (in-list (directory-list (current-directory)))])
    (let ([src-path (build-path (current-directory) src-item)])
      (unless (equal? src-path build-dir)
        (let ([des-path (build-path build-dir src-item)])
          (copy-directory/files src-path des-path))))))

; Provide statements -----------------------------

(provide/contract
 [stage-to-build-dir (-> (and/c path? absolute-path? directory-exists?) void?)])