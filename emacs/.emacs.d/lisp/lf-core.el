;;; lf-core.el --- Bootstrap, package manager, and base defaults -*- lexical-binding: t; -*-
;;; Commentary:
;; Bootstraps elpaca, sets up use-package integration, configures exec-path,
;; base Emacs defaults, global minor modes, auth-source, abbrevs, and utility fns.

;;; Code:

;; ──────────────────────────────────────────────
;; Elpaca Bootstrap
;; ──────────────────────────────────────────────

(defvar elpaca-installer-version 0.12)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth)
                                                            "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil))
      (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install use-package support
(elpaca elpaca-use-package
  (elpaca-use-package-mode))

;; Block until current queue is processed (needed so subsequent use-package forms work)
(elpaca-wait)

;; ──────────────────────────────────────────────
;; exec-path from shell
;; ──────────────────────────────────────────────

(defun emacs-solo/set-exec-path-from-shell-PATH ()
  "Set up Emacs' `exec-path' and PATH the same as the user's shell."
  (interactive)
  (let* ((shell (getenv "SHELL"))
         (shell-name (file-name-nondirectory shell))
         (command
          (cond
           ((string= shell-name "fish") "fish -c 'string join : $PATH'")
           ((string= shell-name "zsh")  "zsh -i -c 'printenv PATH'")
           ((string= shell-name "bash") "bash --login -c 'echo $PATH'")
           (t nil))))
    (if (not command)
        (message "emacs-solo: Unsupported shell: %s" shell-name)
      (let ((path-from-shell
             (replace-regexp-in-string
              "[ \t\n]*$" ""
              (shell-command-to-string command))))
        (when (and path-from-shell (not (string= path-from-shell "")))
          (setenv "PATH" path-from-shell)
          (setq exec-path (split-string path-from-shell path-separator))
          (message ">>> emacs-solo: PATH loaded from %s" shell-name))))))

(defun lf/fix-mise-path ()
  "Ensure mise and asdf shims directories are first in exec-path and PATH."
  (interactive)
  (dolist (shims (list (expand-file-name "~/.local/share/mise/shims")
                       (expand-file-name "~/.asdf/shims")))
    (when (file-directory-p shims)
      (unless (member shims exec-path)
        (push shims exec-path))
      (let ((path (getenv "PATH")))
        (unless (string-search shims path)
          (setenv "PATH" (concat shims ":" path)))))))

(add-to-list 'exec-path (expand-file-name "~/.local/bin"))
(add-to-list 'exec-path (expand-file-name "~/.asdf/shims"))
(add-hook 'after-init-hook #'emacs-solo/set-exec-path-from-shell-PATH)
(add-hook 'after-init-hook #'lf/fix-mise-path)
(add-hook 'find-file-hook #'lf/fix-mise-path)
(add-hook 'eshell-mode-hook #'lf/fix-mise-path)

;; ──────────────────────────────────────────────
;; Startup time message
;; ──────────────────────────────────────────────

(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs ready in %.2f seconds with %d garbage collections."
                     (float-time (time-subtract after-init-time before-init-time))
                     gcs-done)))

;; ──────────────────────────────────────────────
;; Maximized frame
;; ──────────────────────────────────────────────

(push '(fullscreen . maximized) default-frame-alist)

;; ──────────────────────────────────────────────
;; Base Emacs defaults
;; ──────────────────────────────────────────────

(use-package emacs
  :ensure nil
  :custom
  ;; Encoding
  (prefer-coding-system 'utf-8)
  (set-default-coding-systems 'utf-8)
  ;; Scratch / startup
  (inhibit-startup-message t)
  (initial-scratch-message nil)
  (initial-major-mode 'fundamental-mode)
  (initial-buffer-choice t)
  ;; Editing
  (use-short-answers t)
  (sentence-end-double-space nil)
  (fill-column 80)
  (comment-style 'multi-line)
  (column-number-mode t)
  (size-indication-mode t)
  (indicate-empty-lines t)
  ;; Scrolling
  (scroll-conservatively 5)
  (scroll-margin 5)
  (scroll-step 1)
  ;; Uniquify buffer names
  (uniquify-buffer-name-style 'forward)
  ;; Ring bell
  (ring-bell-function 'ignore)
  ;; Byte-compile
  (byte-compile-verbose nil)
  (byte-compile-warnings '(cl-functions))
  ;; Auto-save and backups
  (auto-save-file-name-transforms `((".*" ,(expand-file-name "auto-saves/" user-emacs-directory) t)))
  (backup-directory-alist `((".*" . ,(expand-file-name "backups/" user-emacs-directory))))
  (backup-by-copying t)
  (delete-old-versions t)
  (kept-new-versions 6)
  (kept-old-versions 2)
  (version-control t)
  ;; TRAMP
  (tramp-copy-size-limit (* 2 1024 1024))
  (tramp-use-scp-direct-remote-copying t)
  (tramp-verbose 2)
  ;; Misc
  (global-goto-address-mode 1)
  (kill-do-not-save-duplicates t)
  :config
  ;; Ensure backup dirs exist
  (make-directory (expand-file-name "auto-saves" user-emacs-directory) t)
  (make-directory (expand-file-name "backups" user-emacs-directory) t)
  (make-directory (expand-file-name "cache" user-emacs-directory) t)

  ;; Point custom-file away from init.el
  (setq custom-file (expand-file-name "custom.el" user-emacs-directory))
  (when (file-exists-p custom-file)
    (load custom-file 'noerror))

  ;; TRAMP optimizations
  (connection-local-set-profile-variables
   'remote-direct-async-process
   '((tramp-direct-async-process . t)))
  (connection-local-set-profiles
   '(:application tramp :protocol "scp")
   'remote-direct-async-process)
  (with-eval-after-load 'tramp
    (with-eval-after-load 'compile
      (remove-hook 'compilation-mode-hook #'tramp-compile-disable-ssh-controlmaster-options)))
  (setopt tramp-persistency-file-name (expand-file-name "cache/tramp" user-emacs-directory)))

;; ──────────────────────────────────────────────
;; Global minor modes
;; ──────────────────────────────────────────────

(delete-selection-mode 1)
(global-auto-revert-mode 1)
(recentf-mode 1)
(save-place-mode 1)
(savehist-mode 1)
(winner-mode 1)
(column-number-mode 1)

;; text-mode word wrap
(add-hook 'text-mode-hook #'toggle-word-wrap)

;; ──────────────────────────────────────────────
;; Auth-source
;; ──────────────────────────────────────────────

(use-package auth-source
  :ensure nil
  :defer t
  :config
  (setq auth-sources (list (expand-file-name "~/.authinfo.gpg")))
  (setq user-full-name "Hien Huynh-Minh"
        user-email-address "blackcat22121996@gmail.com")
  (when (file-exists-p "~/.password-store")
    (auth-source-pass-enable)))

;; ──────────────────────────────────────────────
;; Personal variables
;; ──────────────────────────────────────────────

(defvar my-org-inbox-file "~/org/inbox.org"
  "Path to the primary Org inbox file for capture.")

;; ──────────────────────────────────────────────
;; Abbreviation table
;; ──────────────────────────────────────────────

(use-package abbrev
  :ensure nil
  :config
  (define-abbrev-table 'global-abbrev-table
    '(("ra" "→")
      ("la" "←")
      ("ua" "↑")
      ("da" "↓")
      ("clog" "console.log(\">>> LOG:\", {@})"
       (lambda () (search-backward "@") (delete-char 1)))
      ("cwarn" "console.warn(\">>> WARN:\", {@})"
       (lambda () (search-backward "@") (delete-char 1)))
      ("cerr" "console.error(\">>> ERR:\", {@})"
       (lambda () (search-backward "@") (delete-char 1)))
      ("fn" "function() {\n  \n}"
       (lambda () (search-backward "}") (forward-line -1) (end-of-line)))
      ("afn" "async function() {\n  \n}"
       (lambda () (search-backward "}") (forward-line -1) (end-of-line)))
      ("ife" "(function() {\n  \n})();"
       (lambda () (search-backward ")();") (forward-line -1) (end-of-line)))
      ("rfc" "const ${1:ComponentName} = () => {\n  return (\n    <div>@</div>\n  );\n};"
       (lambda () (search-backward "@") (delete-char 1)))
      ("imp" "import {} from '@';"
       (lambda () (search-backward "@") (delete-char 1)))
      ("cb" "```@\n\n```"
       (lambda () (search-backward "@") (delete-char 1)))
      ("todo"  "👷 TODO:")
      ("fixme" "🔧 FIXME:")
      ("note"  "ℹ️ NOTE:")
      ("nb" "&nbsp;")
      ("lt" "&lt;")
      ("gt" "&gt;"))))

;; ──────────────────────────────────────────────
;; Garbage Collector
;; ──────────────────────────────────────────────
(use-package gcmh
  :ensure t
  :config
  (gcmh-mode 1))

;; ──────────────────────────────────────────────
;; Keep emacs config folder clean
;; ──────────────────────────────────────────────
(use-package no-littering
  :ensure t
  :init
  (setq no-littering-etc-directory
	(expand-file-name "etc/" user-emacs-directory))
  (setq no-littering-var-directory
	(expand-file-name "var/" user-emacs-directory)))

;; ──────────────────────────────────────────────
;; Captures shell PATH
;; ──────────────────────────────────────────────
(use-package envrc
  :ensure t
  :hook (after-init . envrc-global-mode))

;; ──────────────────────────────────────────────
;; Utility functions
;; ──────────────────────────────────────────────

(defun mode-has-lsp-p ()
  "Return non-nil if the current major mode has an LSP server configured in Eglot."
  (require 'eglot nil t)
  (and (buffer-file-name)
       (ignore-errors (cl-fourth (eglot--guess-contact)))))

(defun move-line-up (arg)
  "Move current line up by ARG lines."
  (interactive "*p")
  (let ((col (current-column)))
    (dotimes (_ arg)
      (transpose-lines 1)
      (forward-line -2))
    (move-to-column col)))

(defun move-line-down (arg)
  "Move current line down by ARG lines."
  (interactive "*p")
  (let ((col (current-column)))
    (dotimes (_ arg)
      (forward-line 1)
      (transpose-lines 1)
      (forward-line -1))
    (move-to-column col)))

(defun my/copy-buffer-file-path-to-clipboard ()
  "Copy the full path of the current buffer's file to the clipboard."
  (interactive)
  (let ((filepath (buffer-file-name)))
    (when filepath
      (kill-new filepath)
      (message "Copied file path: %s" filepath))))

(provide 'lf-core)
;;; lf-core.el ends here
