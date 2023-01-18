#lang racket
(require "setup.rkt"
         "util.rkt"
         "title.rkt"
         "open-compiler.rkt"
         racket/gui/base
         slideshow slideshow/play pict/shadow)

(provide introduction)

(define (introduction)
  (title->thesis)

  (slide
   (scale (vc-append
           10
           (tt "#define")
           (hbl-append 40 (t "cpp") (t "m4"))
           (blank 0 20)
           (colorize (t "Not these macros!") "red"))
          2))

  (slide
   (lt-superimpose
    (scale-to-fit (bitmap (build-path paper-images "aim-057.png"))
                  client-w client-h)
    (colorize (linewidth 8 (frame (inset (scale (t "From 1963") 1.5) 20 10))) "red")))

  (important-papers)

  (with-title "What is an Open Compiler?"
    (open-compiler-part1)))

(define plt-title-background-with-insets
  (cc-superimpose
   (inset (colorize
           (filled-rectangle (+ client-w margin margin)
                             (+ client-h margin margin))
           plt-background-color)
          (- margin))
   (inset (make-plt-title-background plt-red-color
                                     plt-blue-color
                                     (make-object color% 0 0 0 0) ; plt-background-color
                                     plt-lambda-color
                                     plt-pen-color
                                     plt-pen-style
                                     #:clip? #f)
          -800 0 0 -400)))

(define (title->thesis)
  (define title (scale (t "Modern Macros") 2))
  (define title-phase1 (ghost (launder title)))
  (define title-phase2 (ghost (launder title)))
  (define phase1
    (cc-superimpose
     plt-title-background-with-insets
     (vc-append
      title
      (blank 0 100)
      (vl-append
       (t "Robby Findler")
       (t "Northwestern University")))))
  (define phase2
    (vl-append
     (inset (colorize (t "Thesis:") "red") -20 0 0 0)
     (vc-append
      20
      title
      (scale (t "are an") 2)
      (scale (t "Open Compiler") 2))))

  (play-n
   (λ (n1)
     (superimpose-at
      (cellophane phase1 (- 1 n1))
      phase2
      title))))

(define (superimpose-at p1 p2 at)
  (define-values (p1x p1y) (lt-find p1 at))
  (define-values (p2x p2y) (lt-find p2 at))
  (pin-under
   p1
   (- p1x p2x)
   (- p1y p2y)
   p2))

(define (important-papers)
  (define p1986 (paper 1986))
  (define p1990 (paper 1990))
  (define p1992 (paper 1992))
  (define p2002 (paper 2002))
  (define p2016 (paper 2016))
  (define papers (list p1986 p1990 p1992 p2002 p2016))
  (define ph (apply max (map pict-height papers)))
  (define sized-papers
    (for/list ([paper (in-list papers)])
      (scale paper (/ ph (pict-height paper)))))
  
  (define (s p) (slide (scale-to-fit p client-w client-h)))
  
  (s p1986)

  (with-title "Five Deep Technical Results Over 30 Years"
    (slide
     (scale-to-fit (apply hc-append sized-papers)
                   client-w client-h))))

(define (slide-and-scale main p start finish n)
  (define-values (sl st) (lt-find main start))
  (define-values (sr sb) (rb-find main start))
  (define-values (fl ft) (lt-find main finish))
  (define-values (fr fb) (rb-find main finish))
  (define sw (- sr sl))
  (define fw (- fr fl))
  (define sh (- sb st))
  (define fh (- fb ft))
  (pin-over
   main
   (interpolate sl fl n)
   (interpolate st ft n)
   (scale p
          (/ (interpolate sw fw n) (pict-width p))
          (/ (interpolate sh fh n) (pict-height p)))))
         
(define (paper name)
  (define filename
    (cond
      [(number? name)
       (for/or ([file (in-list (directory-list paper-images))])
         (and (regexp-match? (~a "^" name) (path->bytes file))
              file))]
      [else name]))
  (shadow-frame
   (lt-superimpose
    (bitmap
     (build-path paper-images filename))
    (if (number? name)
        (scale (inset (colorize (t (~a name)) "red") 10) 3)
        (blank)))))

(module+ main (introduction))