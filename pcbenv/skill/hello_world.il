;; -*- mode: lisp -*-

;; SKILL File: etch_visible.il
;; Version: 20251127.1204
;; Description: Hello World minimal example

;; How To Execute:
;;   Command> hello
;;   Command> skill hello_world

axlCmdRegister("hello" 'hello_world)

(defun hello_world ()
  (printf "Hello World!"))

;; This is for the sake of Emacs.
;; Local Variables:
;; time-stamp-end: "$"
;; time-stamp-format: "%:y%02m%02d.%02H%02M"
;; time-stamp-start: "Version: "
;; End:
