;;; init.el --- Little Fox Emacs — thin module loader -*- lexical-binding: t; -*-
;;; Commentary:
;; Adds lisp/ to load-path, then requires modules in dependency order.
;; All package management is handled by elpaca (bootstrapped in lf-core).

;;; Code:

;; Add lisp/ to load-path
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;; ── Load modules in order ───────────────────────────────────────────
(require 'lf-core)        ; elpaca bootstrap, exec-path, base defaults
(require 'lf-shell)       ; eshell + custom prompt
(require 'lf-ui)          ; fonts, theme, modeline, icons
(require 'lf-completion)  ; vertico, consult, embark, corfu, cape
(require 'lf-prog)        ; eglot, treesit, apheleia, dev tools
(require 'lf-lang-go)     ; Go + gopls
(require 'lf-lang-ruby)   ; Ruby + solargraph
(require 'lf-lang-rust)   ; Rust + rust-analyzer
(require 'lf-lang-web)    ; JS/TS/React + typescript-language-server
(require 'lf-org)         ; Org-mode, Denote, presentations
(require 'lf-techlead)    ; tech lead workflow: projects, team, decisions
(require 'lf-ai)          ; GPTel (OpenAI + Claude)
(require 'lf-web)         ; EWW, elfeed
(require 'lf-keys)        ; global keybindings, hydra

;; ── Private settings (gitignored) ──────────────────────────────────
;; Put API keys, machine-specific paths, and personal settings here.
(let ((private (expand-file-name "private.el" user-emacs-directory)))
  (when (file-exists-p private)
    (load private)))

;;; init.el ends here
