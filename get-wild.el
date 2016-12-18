;;; get-wild.el --- Get wild and tough -*- lexical-binding: t; -*-

;; Copyright (C) 2016 by Daichi HIRATA

;; Author: Daichi HIRATA <hirata.daichi@gmail.com>
;; URL: https://github.com/daichirata/emacs-get-wild
;; Version: 0.1.0

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Get-wild.el is a package that increases programming efficiency.
;; You listen to the get wild, it prevents the hand from stopping.
;;
;; To use this package, add these lines to your .emacs file:
;;     (require 'get-wild)
;;
;; And you call 'M-x get-wild'.
;;

;;; Code:
(defcustom get-wild-path ""
  "Path to sound source file"
  :type 'string
  :group 'get-wild)

(defcustom get-wild-timeout-seconds 1
  "Timeout seconds for `run-with-idle-timer'"
  :type 'integer
  :group 'get-wild)

(defcustom get-wild-cheap-thrills nil
  "To give oneself to cheap thrills"
  :type 'boolean
  :group 'get-wild)

(defvar get-wild-buffer "*get-wild*")
(defvar get-wild-player-status nil)
(defvar get-wild-process nil)

(defun get-wild-ensure-process ()
  (unless (process-live-p get-wild-process)
    (setq get-wild-process (start-process-shell-command "get-wild" get-wild-buffer (concat "mplayer -quiet -loop 0 -slave " get-wild-path)))
    (get-wild-player-send-pause)))

(defun get-wild-delete-process ()
  (when (process-live-p get-wild-process)
    (delete-process get-wild-process)))

(defun get-wild-player-send-pause ()
  (when (process-live-p get-wild-process)
    (process-send-string get-wild-process "pause\n")))

(defun get-wild-player-stop ()
  (when get-wild-player-status
    (setq get-wild-player-status nil)
    (get-wild-player-send-pause)))

(defun get-wild-player-start ()
  (get-wild-ensure-process)
  (unless get-wild-player-status
    (setq get-wild-player-status t)
    (get-wild-player-send-pause)))

(defun get-wild-to-give-oneself-to-cheap-thrills ()
  (when (zerop (random 99999))
    (delete-file (buffer-file-name))
    (set-buffer-modified-p nil)
    (kill-this-buffer)))

(defun post-command-hook--get-wild ()
  (ignore-errors
    (when (member last-command-event (number-sequence ?! ?z))
      (when get-wild-cheap-thrills
        (get-wild-to-give-oneself-to-cheap-thrills))
      (get-wild-player-start))))

(defun get-wild-and-tough ()
  (add-hook 'post-command-hook 'post-command-hook--get-wild)
  (run-with-idle-timer get-wild-timeout-seconds t 'get-wild-player-stop))

(defun release-wild-and-tough ()
  (get-wild-delete-process)
  (kill-buffer get-wild-buffer)
  (remove-hook 'post-command-hook 'post-command-hook--get-wild)
  (cancel-function-timers 'get-wild-player-stop))

;;;###autoload
(define-minor-mode get-wild-mode
  "`get-wild' prevents the hand from stopping"
  :init-value nil
  :global nil
  :lighter " GetWild"
  (if get-wild-mode
      (get-wild-and-tough)
    (release-wild-and-tough)))

(provide 'get-wild)
;;; get-wild.el ends here
