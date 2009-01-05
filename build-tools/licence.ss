#lang scheme/base

(require (for-syntax scheme/base)
         scheme/contract
         scheme/file
         scheme/match
         scheme/port
         srfi/13
         srfi/26
         (planet untyped/unlib:3/debug)
         (planet untyped/unlib:3/file)
         "info.ss")

; Helpers ----------------------------------------

; string -> string
(define (format-licence/plain text)
  (if (regexp-match #rx"[\n\r][ ]*$" text)
      text
      (format "~a~n" text)))

; string -> string
(define (format-licence/scheme text)
  ; string
  (define text/intermediate
    (string-trim-both (regexp-replace* #rx"\n" text "\n; ")))
  
  ; string
  (define text/first
    (if (regexp-match #rx"^;" text/intermediate)
        text/intermediate
        (format "; ~a" text/intermediate)))
  
  (format-licence/plain text/first))

; Syntax -----------------------------------------

; (_ string [rx string] ...)
(define-syntax regexp-replace-all
  (syntax-rules ()
    [(_ str) str]
    [(_ str [rx val] [rxs vals] ...)
     (regexp-replace* rx (regexp-replace-all str [rxs vals] ...) val)]))

; (_ id path-spec info)
;
; expands to: (licence-type -> string)
;
; where licence-type : (U 'plain 'scheme)
(define-syntax licence-maker
  (syntax-rules ()
    [(_ info template-file)
     (let ([licence (regexp-replace-all
                     (string-trim-both (file->string template-file))
                     [#rx"@\\|name\\|"             (package-info-name info)]
                     [#rx"@\\|version\\|"          (package-info-version info)]
                     [#rx"@\\|copyright-holder\\|" (package-info-copyright-holder info)]
                     [#rx"@\\|copyright-year\\|"   (package-info-copyright-year info)])])
       (match-lambda
         ['scheme (format-licence/scheme licence)]
         ['plain  (format-licence/plain  licence)]))]))

; Procedures -------------------------------------

; path string -> void
(define (licence-scheme-file path licence)
  (let ([lines (file->lines path)])
    (with-output-to-file path
      (lambda ()
        (for/fold ([in-header? #t])
                  ([line (in-list lines)])
                  (if in-header?
                      (if (regexp-match #rx"^(#!|#lang)" line)
                          (begin
                            (printf "~a~n" line)
                            #t)
                          (begin
                            (printf "~n~a~a~n" licence line)
                            #f))
                      (begin
                        (printf "~a~n" line)
                        #f))))
      #:mode   'text
      #:exists 'replace)
    (void)))

; path string -> void
(define (licence-scheme-files build-dir licence)
  ; path -> boolean
  (define (scheme-file? path)
    (and (file-exists? path)
         (regexp-match #rx"(ss|scm)$" (path->string path))
         #t))
  
  ; (listof path)
  (define scheme-files
    (directory-tree build-dir #:filter scheme-file?)) 
  
  (for-each (cut licence-scheme-file <> licence)
            scheme-files))

; path string -> void
;
; Overwrites the *licence-file* with a new licence generated from
; *licence-template*.
(define (recreate-licence-file path licence)
  ; void
  (with-output-to-file path
    (lambda ()
      (display licence))
    #:mode   'text
    #:exists 'replace))

; Provide statements -----------------------------

(provide licence-maker)

(provide/contract
 [format-licence/plain  (-> string? string?)]
 [format-licence/scheme (-> string? string?)]
 [licence-scheme-file   (-> (and/c path? absolute-path? file-exists?) string? void?)]
 [licence-scheme-files  (-> (and/c path? absolute-path? directory-exists?) string? void?)]
 [recreate-licence-file (-> (and/c path? absolute-path?) string? void?)])
