;;; early-init.el --- Early initialization -*- lexical-binding: t -*-
;;; Commentary:
;; This file is loaded before init.el for startup optimization.
;;; Code:

;; Increase garbage collection threshold during startup (100MB)
;; This prevents GC from running during init, which is slow
(setq gc-cons-threshold (* 100 1024 1024))
(setq gc-cons-percentage 0.6)


;; Disable file-name-handler-alist during startup
;; Saves time on file operations during init
(defvar default-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

;; Disable UI elements early (before frame is drawn)
;; Much faster than disabling after frame creation
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(setq menu-bar-mode nil
      tool-bar-mode nil
      scroll-bar-mode nil)

;; Don't resize frame at startup
(setq frame-inhibit-implied-resize t)

;; Disable startup messages
(setq inhibit-startup-message t
      inhibit-startup-echo-area-message user-login-name
      inhibit-default-init t)

;; Native compilation settings
(when (featurep 'native-compile)
  ;; Silence native-comp warnings
  (setq native-comp-async-report-warnings-errors 'silent)
  ;; Set native-comp cache directory
  (when (fboundp 'startup-redirect-eln-cache)
    (startup-redirect-eln-cache
     (expand-file-name "eln-cache/" user-emacs-directory))))

;; Disable package.el — elpaca takes over package management
;; Must be set before package.el is loaded (hence early-init.el)
(setq package-enable-at-startup nil)

;; Prefer newer files (compiled or source)
(setq load-prefer-newer t)

;; Restore settings after startup
(add-hook 'emacs-startup-hook
          (lambda ()
            ;; Restore file-name-handler-alist
            (setq file-name-handler-alist default-file-name-handler-alist)
            ;; Lower GC threshold after startup (16MB)
            (setq gc-cons-threshold (* 16 1024 1024))
            (setq gc-cons-percentage 0.1)
            ;; Garbage collect on focus loss
            (add-hook 'focus-out-hook #'garbage-collect)))

;; Suppress known harmless elpaca warning
(setq warning-suppress-types '((emacs)))
(setq warning-suppress-log-types '((emacs)))

;;; early-init.el ends here
