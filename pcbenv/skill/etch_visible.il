;;; -*- mode: lisp -*-

;; SKILL File: etch_visible.il
;; Version: 20210827.0858
;; Description: Change the visibility of Etch Cadence Allegro layers

;; Author  : Yuriy Gritsenko
;; URL     : https://github.com/yuravg/allegro-configs
;; License : MIT License

;;; Commentary:
;; Allegro SKILL Reference
;;   <cdsroot>/doc/algroskill/algroskillTOC.html
;;   (<cdsroot> path to Allegro, for example C:/Cadence/SPB_17.2)
;; Allegro PCB Editor SKILL Functions:
;;   <cdsroot>/doc/algroskill/04parmgt.html#pgfId-1069532

;; Functions:
;;   etch_visible            - Set VISIBLE for Etch LAYER_NAME and Update the window
;;   etch_number_visible     - Set VISIBLE for Etch layer NUMBER in the cross section
;;   toggle_visible          - Toggle the visibility of the Etch layer by its NAME
;;   toggle_number_visible   - Toggle the visibility of the Etch layer by its NUMBER in the cross section
;;   toggle_conductor_layers - Toggle the visibility of all 'Conductor' layers
;;   toggle_plane_layers     - Toggle the visibility of all 'PLANE' layers
;;   toggle_layers           - Toggle the visibility of all layers
;;   etch_list               - Displaying Etch layer names

;; TODO:
;; - rename lv alias to tv (toggle layer)
;; - add command lv for any layer names and visible value

;; How To Execute:
;;   Command> etch_visible TOP t
;;   Command> etch_visible TOP nil
;;   Command> etch_number_visible 2 t
;;   Command> etch_number_visible 2 nil
;;   Command> toggle_visible TOP
;;   Command> toggle_number_visible 1
;;   Command> toggle_conductor_layers
;;   Command> toggle_plane_layers
;;   Command> toggle_layers
;;   Command> etch_list
;;   Command> skill toggle_visible "TOP"
;;   Command> skill etch_visible "TOP" t
;;   Command> skill etch_visible "TOP" nil
;;   Command> skill etch_number_visible 2 t
;;   Command> skill etch_number_visible 2 nil
;;   Command> skill toggle_number_visible 1
;;   Command> skill etch_list

axlCmdRegister("etch_visible" 'etch_visible ?cmdType "general")
axlCmdRegister("etch_number_visible" 'etch_number_visible ?cmdType "general")
axlCmdRegister("toggle_visible" 'toggle_visible ?cmdType "general")
axlCmdRegister("toggle_number_visible" 'toggle_number_visible ?cmdType "general")
axlCmdRegister("toggle_conductor_layers" 'toggle_conductor_layers ?cmdType "general")
axlCmdRegister("toggle_plane_layers" 'toggle_plane_layers ?cmdType "general")
axlCmdRegister("toggle_layers" 'toggle_layers ?cmdType "general")
axlCmdRegister("etch_list" 'etch_list ?cmdType "general")

;; Alias 'lv' abbreviation from 'Layer Visible'
;; How To Execute:
;;   Command> lv 1
axlCmdRegister("lv" 'toggle_number_visible ?cmdType "general")

;; TODO: usage toggle number and other commands with list of numbers, for example
;;       Command> toggle_number_visible 1 3 4

;; Return a list of all Etch layer names
(defun _get_etch_list ()
  (let (etch_parm etch_list)
    (setq etch_parm (axlGetParam "paramLayerGroup:ETCH"))
    (setq etch_list etch_parm->groupMembers)))

;; Return a list of all Etch layer names for a special layer TYPE
(defun _get_ltype_etch_list (type)
  (let (etch_parm etch_list etch_type_list)
    (setq etch_parm (axlGetParam "paramLayerGroup:ETCH"))
    (setq etch_list etch_parm->groupMembers)
    (setq etch_type_list '())
    (foreach layer (_get_etch_list)
             (if (eq (strcmp (axlDBGetLayerType layer)
                             type)
                     0)
                 (setq etch_type_list
                       (append etch_type_list
                               (list layer)))))
    etch_type_list))

;; Displaying Etch layer names
(defun etch_list ()
  (let ((index 1))
    (foreach layer (_get_etch_list)
             (printf "%02d: %s   %s\n"
                     (index++)
                     layer
                     (if (eq (strcmp (axlDBGetLayerType layer)
                                     "PLANE")
                             0)
                         "(plane)"
                       "")))
    t)) ; 'return t' to prevent message as ("TOP"..."BOTTOM") for run via 'Command> skill etch_list'

;; Return the name of the Etch layer by serial number in the cross section
(defun _ethc_number2name (number)
  (nthelem (number--) (_get_etch_list)))

;; Set VISIBLE for Etch LAYER_NAME
(defun _set_etch_visible (layer_name visible verbosity)
  (if (stringp layer_name)
      (progn
        (let ((class_name '("DRC ERROR CLASS"
                            "ETCH"
                            "PIN"
                            "VIA CLASS"
                            "ANTI ETCH")))
          (foreach i class_name
                   (setq i (strcat i "/" layer_name))
                   (axlVisibleLayer i visible)))
        (if verbosity
            (printf "Etch '%s' %s"
                    layer_name
                    (if visible "visible" "invisible"))))
    (printf "Warning: can not find Etch!")))

;; Set VISIBLE for Etch LAYER_NAME
;; (Update the window for use from 'Command' windows)
(defun etch_visible (layer_name visible)
  (if (stringp visible)  ; for use from 'Command' windows
      (if (eq (strcmp visible "t")
              0)
          (setq visible t)
        (setq visible nil)))
  (_set_etch_visible layer_name visible t)
  (axlVisibleUpdate t))

;; Set VISIBLE for Etch layer NUMBER in the cross section
;; (for use from 'Command' windows)
(defun etch_number_visible (number visible)
    (if (stringp number)    ; for use from 'Command' windows
      (setq number (atoi (car (parseString number)))))
  (etch_visible (_ethc_number2name number) visible))

;; Returns the visibility (t/nil) of the Etch layer NAME
(defun _etch_is_visible (name)
  (if (stringp name) ; Check the type to prevent: *Error* strcat: argument #3 should be either a string or a symbol (type template = "S") - nil
      (axlIsVisibleLayer
       (strcat "ETCH"   ; Class
               "/"
               name)))) ; Subclass

;; Returns the visibility (t/nil) of the Etch layer by its NUMBER in the cross section
(defun _etch_is_number_visible (number)
  (_etch_is_visible (_ethc_number2name number)))

;; Toggle the visibility of the Etch layer by its NAME
;; (Update the window for use from 'Command' windows)
(defun toggle_visible (name)
  (if (_etch_is_visible name)
      (_set_etch_visible name nil t)
    (_set_etch_visible name t t))
  (axlVisibleUpdate t))

;; Toggle the visibility of the Etch layer by its NUMBER in the cross section
(defun toggle_number_visible (number)
  (if (stringp number)    ; for use from 'Command' windows
      (setq number (atoi (car (parseString number)))))
  (toggle_visible (_ethc_number2name number)))

;; Toggle visibility for all layers depending on the them TYPE
;;  if at least one layer is visible, then all layers are switched to invisible
;;  (Update the window for use from 'Command' windows)
(defun _toggle_type_layers (type)
  (let ((visible t)
        (layer_list (_get_ltype_etch_list type)))
    (foreach layer layer_list
             (if (_etch_is_visible layer)
                 (setq visible nil)))
    (foreach layer layer_list
             (_set_etch_visible layer visible nil))
    (printf "All %s layers are %s"
            (lowerCase type)
            (if visible "visible" "invisible")))
  (axlVisibleUpdate t))

;; Toggle the visibility of all 'Conductor' layers
(defun toggle_conductor_layers ()
  (_toggle_type_layers "CONDUCTOR"))

;; Toggle the visibility of all 'PLANE' layers
(defun toggle_plane_layers ()
  (_toggle_type_layers "PLANE"))

;; Toggle visibility of all layers
;;  if at least one 'conductor' layer is visible, then all layers are switched to invisible
;;  (Update the window for use from 'Command' windows)
(defun toggle_layers ()
  (let ((visible t)
        (cond_list (_get_ltype_etch_list "CONDUCTOR"))
        (plane_list (_get_ltype_etch_list "PLANE")))
    (foreach layer cond_list
             (if (_etch_is_visible layer)
                 (setq visible nil)))
    (foreach layer cond_list
             (_set_etch_visible layer visible nil))
    (foreach layer plane_list
             (_set_etch_visible layer visible nil))
    (printf "All layers are %s"
            (if visible "visible" "invisible")))
  (axlVisibleUpdate t))

;; This is for the sake of Emacs.
;; Local Variables:
;; time-stamp-end: "$"
;; time-stamp-format: "%:y%02m%02d.%02H%02M"
;; time-stamp-start: "Version: "
;; End:
