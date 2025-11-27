;;; -*- mode: lisp -*-

;; SKILL File: display_options.il
;; Version: 20251127.1249
;; Description: Control display options in Parameters Editor (toggle, enable, disable)

;; Author  : Yuriy Gritsenko
;; URL     : https://github.com/yuravg/allegro-configs
;; License : MIT License

;;; Commentary:
;; Allegro SKILL Reference
;;   <cdsroot>/doc/algroskill/algroskillTOC.html
;;   (<cdsroot> path to Allegro, for example C:/Cadence/SPB_17.2)
;; Allegro PCB Editor SKILL Functions:
;;   <cdsroot>/doc/algroskill/04parmgt.html#pgfId-1069532

;; How To Execute:
;;   Command> toggle_filled_pads
;;   Command> skill enable_filled_pads
;;   Command> skill disable_filled_pads

axlCmdRegister("toggle_filled_pads" 'toggle_filled_pads)

(defun toggle_filled_pads ()
  "Toggle filled pads display"
  ;; Use state variable to track and toggle
  (unless (boundp 'g_filled_pads_state)
    (setq g_filled_pads_state nil))

  (if g_filled_pads_state
      (axlShellPost "skill disable_filled_pads")
      (axlShellPost "skill enable_filled_pads")))

(defun enable_filled_pads ()
  "Enable filled pads display"
  (axlShell "prmed; setwindow form.prmedit; FORM prmedit display_enhance YES; FORM prmedit apply; FORM prmedit done; setwindow pcb")
  (setq g_filled_pads_state t)
  (printf "Filled pads: ENABLED"))


(defun disable_filled_pads ()
  "Disable filled pads display"
  (axlShell "prmed; setwindow form.prmedit; FORM prmedit display_enhance NO; FORM prmedit apply; FORM prmedit done; setwindow pcb")
  (setq g_filled_pads_state nil)
  (printf "Filled pads: DISABLED"))

;; This is for the sake of Emacs.
;; Local Variables:
;; time-stamp-end: "$"
;; time-stamp-format: "%:y%02m%02d.%02H%02M"
;; time-stamp-start: "Version: "
;; End:
