;;; bw-interactive.el --- Functions for interactive resize of windows
;;
;; Description:
;; Author: Lennart Borgman <lennart dot borgman dot 073 at student at lu at se>
;; Maintainer:
;; Created: Wed Dec 07 15:35:09 2005
;; Version: 0.7
;; Last-Updated: Tue Jul 18 00:29:25 2006 (7200 +0200)
;; Keywords:
;; Compatibility:
;;
;; Features that might be required by this library:
;;
;;   None
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:
;;
;; This file contains functions for interactive resizing of Emacs
;; windows. To use it put it in your `load-path' and add the following
;; to your .emacs:
;;
;;     (require 'bw-interactive)
;;     (global-set-key [(control x) ?+] 'bw-start-resize-mode)
;;
;; Typing "C-x +" will now enter a temporary mode for resizing windows.
;; For more information see `bw-mode-resize'.
;;
;; These functions are the second part of my proposal for a new
;; `balance-windows' function for Emacs. These second part were not
;; accepted into Emacs 22, but you can use this module instead to get
;; the functionality. It requires Emacs 22 from 2006.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Change log:
;;
;; 2005-12-08 Changed to use `overriding-terminal-local-map'.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Code:

;; Check if using new function from Emacs 22
(unless (fboundp 'bw-balance-sub) (require 'bw-base))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Window resizing minor mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun bw-balance-windows()
  "Call `balance-windows' and exit `bw-window-resize-mode'."
  (interactive)
  (balance-windows)
  (bw-exit-resize-mode))

(defun bw-balance-siblings()
  "Make current window siblings the same height or width."
  (interactive)
  (balance-windows (selected-window))
  (bw-exit-resize-mode))

(defun bw-shrink-windows-horizontally()
  "Shrink horizontally any window that could be shrinked to fit buffer."
  (interactive)
  (walk-windows 'shrink-window-if-larger-than-buffer)
  (bw-exit-resize-mode))

(defun bw-exit-resize-mode()
  "Exit bw window resize mode.
See `bw-window-resize-mode'."
  (interactive)(bw-window-resize-mode -1))

(defconst bw-keymap
  (let ((map (make-sparse-keymap "Window Resizing")))
    (define-key map [menu-bar bw]
      (cons "Resize" (make-sparse-keymap "second")))
    (define-key map [menu-bar bw shrink]
      '("Shrink to Buffers" . bw-shrink-windows-horizontally))
    (define-key map [menu-bar bw siblings]
      '("Balance Window Siblings" . bw-balance-siblings))
    (define-key map [menu-bar bw balance]
      '("Balance Windows" . bw-balance-windows))
    (define-key map [t]  'bw-exit-resize-mode)
    (define-key map [?+] 'bw-balance-windows)
    (define-key map [?.] 'bw-balance-siblings)
    (define-key map [?f] 'bw-shrink-windows-horizontally)
    (define-key map [(up)]    'bw-mode-resize-up)
    (define-key map [(down)]  'bw-mode-resize-down)
    (define-key map [(left)]  'bw-mode-resize-left)
    (define-key map [(right)] 'bw-mode-resize-right)
    map)
  "Keymap used by `bw-window-resize-mode'.")

(defvar bw-window-to-resize nil
  "Window selected for resizing.")
(defvar bw-window-to-resize-buffer nil
  "Buffer shown in `bw-window-to-resize'.")
(defvar bw-frame nil "Frame for resizing.")
(defun bw-window-resize-post-command()
  "Exit `bw-window-resize-mode' unless focus is in window to resize.
Added `post-command-hook' in `bw-window-resize-mode'."
  (if (and (not (active-minibuffer-window))
           (eq bw-window-to-resize (selected-window))
           (eq bw-window-to-resize-buffer (window-buffer (selected-window)))
           )
      t
    (bw-window-resize-mode -1)
    nil))



(defun bw-start-resize-mode()
  "Enter bw window resize mode.
See `bw-window-resize-mode'."
  (interactive)
  (if (= 1 (length (window-list)))
      (message "There is only one window on this frame, can't resize that")
    (message "Arrow keys: interactive resize, '+': balance windows, '.': balance siblings")
    (bw-window-resize-mode 1)))

(defvar bw-window-for-side-hor nil
  "Window used internally for resizing in horizontal direction.")
(defvar bw-window-for-side-ver nil
  "Window used internally for resizing in vertical direction.")
(defun bw-mode-resize-left()
  "Decrease or increase window size.

First time a key for vertical (horizontal) enlarging is hit it
moves the mouse cursor to the corresponding window border if that
is not the frame border.  Subsequent hits on such a key moves
that window border.

The name of the function tells which border to handle.

Note: This is modelled after how some GUI window managers do
similar resizing."
  (interactive)(bw-mode-resize -1 t))
(defun bw-mode-resize-right()
  "See `bw-mode-resize-left'."
  (interactive)(bw-mode-resize 1  t))
(defun bw-mode-resize-up()
  "See `bw-mode-resize-left'."
  (interactive)(bw-mode-resize -1 nil))
(defun bw-mode-resize-down()
  "See `bw-mode-resize-left'."
  (interactive)(bw-mode-resize 1  nil))

(defun bw-window-beside(window side)
  "Return a window directly beside WINDOW at side SIDE.
That means one whose edge on SIDE is touching WINDOW.  SIDE
should be a number corresponding to positions in the values
returned by 'window-edges'."
  (let ((start-window window)
        (start-left   (nth 0 (window-edges window)))
        (start-top    (nth 1 (window-edges window)))
        (start-right  (nth 2 (window-edges window)))
        (start-bottom (nth 3 (window-edges window)))
	above-window)
    (setq window (previous-window window 0))
    (while (and (not above-window) (not (eq window start-window)))
      (let (
            (left   (nth 0 (window-edges window)))
            (top    (nth 1 (window-edges window)))
            (right  (nth 2 (window-edges window)))
            (bottom (nth 3 (window-edges window)))
            )
        (if (or (= side 0) (= side 2))
            (when (and (if (= side 0) (= right start-left) (= left start-right))
                       (or (and (<= top start-top)    (<= start-bottom bottom))
                           (and (<= start-top top)    (<= top start-bottom))
                           (and (<= start-top bottom) (<= bottom start-bottom))))
              (setq above-window window))
          (when (and (if (= side 1) (= bottom start-top) (= top start-bottom))
                     (or (and (<= left start-left)  (<= start-right right))
                         (and (<= start-left left)  (<= left start-right))
                         (and (<= start-left right) (<= right start-right))))
            (setq above-window window))))
      (setq window (previous-window window)))
    above-window))

(defun bw-mode-resize(arg horizontal)
  "Used by `bw-mode-resize-left' etc."
  (unless (= (* arg arg) 1)
    (error "ARG must be -1 or 1"))
  (let* ((bw-side (if horizontal 'bw-window-for-side-hor 'bw-window-for-side-ver))
         (preserve-before (eq arg 1))
         (dir (if horizontal 'hor 'ver))
         (moveable t)
         (bside (if horizontal
                    (if (< arg 0) 0 2)
                 (if (< arg 0) 1 3)))
         (window-beside (bw-window-beside (selected-window) bside))
         )
    (if (not (symbol-value bw-side))
        (progn
          (unless window-beside
            (setq moveable nil))
          (when (> arg 0) (setq window-beside (selected-window)))
          (when moveable (set bw-side window-beside)))
      (when bw-window-resize-mode
        (condition-case err
            (adjust-window-trailing-edge (symbol-value bw-side) arg horizontal)
          (error (message "%s" (error-message-string err)))
          )))
    (when (= 1 (length (window-list))) (bw-exit-resize-mode))
    (unless moveable (bw-exit-resize-mode))
    (when (and moveable
               bw-window-resize-mode)
      (bw-move-mouse-to-resized))))

(defun bw-move-mouse-to-resized()
  "Move mouse to the border beeing moved in interactive resize."
  (let* ((edges (window-edges))
         (L (nth 0 edges))
         (T (nth 1 edges))
         (R (nth 2 edges))
         (B (nth 3 edges))
         (x (/ (+ L R) 2))
         (y (/ (+ T B) 2)))
    (when bw-window-for-side-hor
      ;;(setq x (if (= bw-window-for-side-hor -1) (- L 1) (- R 1))))
      (setq x (if (eq (selected-window) bw-window-for-side-hor) (- R 1) (- L 1))))
    (when bw-window-for-side-ver
      ;;(setq y (if (= bw-window-for-side-ver -1) (- T 1) (- B 1))))
      (setq y (if (eq (selected-window) bw-window-for-side-ver) (- B 1) (- T 1))))
    (set-mouse-position (selected-frame) x y)))


(defvar bw-mode-line-old-bg nil)
;;(defvar bw-old-help-event-list nil)
(define-minor-mode bw-window-resize-mode
  "Minor mode temporary used for resizing the selected window.

Normally you start this temporary minor mode by typing
    C-x +

This will start a temporary mode in the current buffer where
    +   means balance windows
    .   balance siblings
    f   shrink windows to fit buffers
    arrow keys: start interactive resizing.

First arrow key pressed tells which border should be moved.
Subsequent arrow keys moves that border.

You should normally not call this function yourself. However if
you do then ARG has the following meaning: nil it toggles the
mode, -1 turns the mode off, 1 turns the mode on."
  :init-value nil
  :lighter " *WINDOW RESIZING*"
  ;;:keymap bw-keymap
  :group 'windows

  (setq bw-window-for-side-hor nil)
  (setq bw-window-for-side-ver nil)
  (if bw-window-resize-mode
      (progn
        (setq bw-keymap (let ((map (make-sparse-keymap)))
                          (set-keymap-parent map bw-keymap)
                          map))
        (dolist (key help-event-list)
          (define-key bw-keymap (vector key) nil))
        (setq bw-window-to-resize (selected-window))
        (setq bw-window-to-resize-buffer (window-buffer (selected-window)))
        (setq bw-frame (selected-frame))
        (add-hook 'post-command-hook 'bw-window-resize-post-command)
        (setq bw-keymap-alist (list (cons 'bw-keymap bw-keymap)))
        (setq overriding-terminal-local-map bw-keymap)
        (setq overriding-local-map-menu-flag t)
        (setq bw-mode-line-old-bg (face-attribute 'mode-line :background))
        (set-face-attribute 'mode-line bw-frame :background "#ff0000")
        ;;(describe-variable 'bw-keymap (get-buffer-create "*Help*"))
        )
    (setq overriding-terminal-local-map nil)
    (setq overriding-local-map-menu-flag nil)
    (setq bw-keymap (keymap-parent bw-keymap))
    (remove-hook 'post-command-hook 'bw-window-resize-post-command)
    (setq bw-window-to-resize nil)
    (setq bw-window-to-resize-buffer nil)
    (when (frame-live-p bw-frame)
      (set-face-attribute 'mode-line bw-frame :background bw-mode-line-old-bg))
    ))


(provide 'bw-interactive)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; bw-interactive.el ends here
