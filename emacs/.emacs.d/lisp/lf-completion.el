;;; lf-completion.el --- Minibuffer and in-buffer completion -*- lexical-binding: t; -*-
;;; Commentary:
;; Configures the full completion stack:
;; Orderless (fuzzy matching), Vertico (vertical minibuffer), Marginalia (annotations),
;; Consult (enhanced commands), Embark (contextual actions), Prescient (sorting),
;; Corfu (in-buffer popup), Cape (completion-at-point extensions), Helpful (better help).
;;
;; Orderless qualifiers:
;;   ! exclude   , initialism   = literal   ~ flex   % char-fold

;;; Code:

;; ──────────────────────────────────────────────
;; Orderless
;; ──────────────────────────────────────────────

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

;; ──────────────────────────────────────────────
;; Vertico
;; ──────────────────────────────────────────────

(use-package vertico
  :ensure t
  :init
  (vertico-mode +1)
  :config
  (setq vertico-count 20)
  (setq vertico-cycle t)
  ;; Fix TRAMP hanging on remote path completion
  (defun my/vertico-disable-for-tramp ()
    "Use basic completion for TRAMP paths to avoid hangs."
    (when (and (minibufferp)
               (vertico--remote-p (minibuffer-contents)))
      (setq-local vertico--lock-candidate t)))
  (add-hook 'minibuffer-setup-hook #'my/vertico-disable-for-tramp)
  :bind (:map vertico-map
              ("M-i"   . vertico-quick-insert)
              ("C-M-n" . vertico-next-group)
              ("C-M-p" . vertico-previous-group)))

;; ──────────────────────────────────────────────
;; Marginalia
;; ──────────────────────────────────────────────

(use-package marginalia
  :ensure t
  :init
  (marginalia-mode)
  :bind (:map minibuffer-local-map
              ("M-A" . marginalia-cycle)))

;; ──────────────────────────────────────────────
;; Consult
;; ──────────────────────────────────────────────

(use-package consult
  :ensure t
  :config
  (setq consult-narrow-key "<")
  (defun lf-buffer-remote-p (buf)
    "Return t when BUF is visiting a remote file."
    (if-let ((fp (buffer-file-name buf)))
        (file-remote-p fp)
      nil))
  (setq consult-preview-excluded-buffers 'lf-buffer-remote-p)
  :bind
  (("C-c M-x" . consult-mode-command)
   ("C-c h"   . consult-history)
   ("C-c k"   . consult-kmacro)
   ("C-c m"   . consult-man)
   ("C-c i"   . consult-info)
   ([remap Info-search] . consult-info)
   ("C-x M-:" . consult-complex-command)
   ("C-x b"   . consult-buffer)
   ("C-x 4 b" . consult-buffer-other-window)
   ("C-x 5 b" . consult-buffer-other-frame)
   ("C-x t b" . consult-buffer-other-tab)
   ("C-x r b" . consult-bookmark)
   ("C-x p b" . consult-project-buffer)
   ("M-y"     . consult-yank-pop)
   ("M-g e"   . consult-compile-error)
   ("M-g f"   . consult-flymake)
   ("M-g g"   . consult-goto-line)
   ("M-g M-g" . consult-goto-line)
   ("M-g o"   . consult-outline)
   ("M-g m"   . consult-mark)
   ("M-g k"   . consult-global-mark)
   ("M-g i"   . consult-imenu)
   ("M-g I"   . consult-imenu-multi)
   ("M-s d"   . consult-find)
   ("M-s c"   . consult-locate)
   ("M-s g"   . consult-grep)
   ("M-s G"   . consult-git-grep)
   ("M-s r"   . consult-ripgrep)
   ("M-s l"   . consult-line)
   ("M-s L"   . consult-line-multi)
   ("M-s k"   . consult-keep-lines)
   ("M-s u"   . consult-focus-lines)
   ("M-s e"   . consult-isearch-history)
   :map isearch-mode-map
   ("M-e"   . consult-isearch-history)
   ("M-s e" . consult-isearch-history)
   ("M-s l" . consult-line)
   ("M-s L" . consult-line-multi)
   :map minibuffer-local-map
   ("M-s" . consult-history)
   ("M-r" . consult-history)))

;; ──────────────────────────────────────────────
;; Consult dir
;; ──────────────────────────────────────────────
(use-package consult-dir
  :ensure t
  :bind (("C-x C-d" . consult-dir)
	 :map vertico-map
	 ("C-x C-d" . consult-dir)
	 ("C-x C-j" . consult-dir-jump-file)))

;; ──────────────────────────────────────────────
;; Embark
;; ──────────────────────────────────────────────

(use-package embark
  :ensure t
  :bind
  (("C-."   . embark-act)
   ("C-:"   . embark-dwim)
   ("C-h B" . embark-bindings)))

(use-package embark-consult
  :ensure t
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; ──────────────────────────────────────────────
;; wgrep — edit grep/ripgrep results in-place
;; ──────────────────────────────────────────────

(use-package wgrep
  :ensure t
  :custom
  (wgrep-auto-save-buffer t)
  (wgrep-change-readonly-file t))

;; ──────────────────────────────────────────────
;; Prescient (frequency/recency sorting)
;; ──────────────────────────────────────────────

(use-package prescient
  :ensure t
  :config
  (prescient-persist-mode +1))

(use-package vertico-prescient
  :ensure t
  :after vertico
  :config
  (vertico-prescient-mode +1))

(use-package corfu-prescient
  :ensure t
  :after corfu
  :config
  (corfu-prescient-mode +1))

;; ──────────────────────────────────────────────
;; Corfu (in-buffer completion popup)
;; ──────────────────────────────────────────────

(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0.1)
  (corfu-popupinfo-delay '(0.4 . 0.2))
  (corfu-cycle t)
  (corfu-preselect 'prompt)
  (corfu-quit-no-match 'separator)
  (corfu-preview-current nil)
  :bind (:map corfu-map
              ("TAB"     . corfu-next)
              ([tab]     . corfu-next)
              ("S-TAB"   . corfu-previous)
              ([backtab] . corfu-previous)
              ("RET"     . corfu-insert)
              ("M-d"     . corfu-popupinfo-toggle))
  :init
  (global-corfu-mode 1)
  :config
  (corfu-history-mode 1)
  (corfu-popupinfo-mode 1))

(use-package nerd-icons-corfu
  :ensure t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;; ──────────────────────────────────────────────
;; Cape (completion-at-point extensions)
;; ──────────────────────────────────────────────

(use-package cape
  :ensure t
  :init
  (add-hook 'completion-at-point-functions #'cape-file -10)
  (add-hook 'completion-at-point-functions #'cape-dabbrev 20)
  :bind (("C-c p f" . cape-file)
         ("C-c p d" . cape-dabbrev)
         ("C-c p k" . cape-keyword)
         ("C-c p s" . cape-elisp-symbol)
         ("C-c p w" . cape-dict)))

;; Better eglot + cape integration
(with-eval-after-load 'eglot
  (advice-add 'eglot-completion-at-point :around #'cape-wrap-buster))

;; ──────────────────────────────────────────────
;; Helpful (better *Help* buffers)
;; ──────────────────────────────────────────────

(use-package helpful
  :ensure t
  :bind (("C-h f"   . helpful-callable)
         ("C-h v"   . helpful-variable)
         ("C-h k"   . helpful-key)
         ("C-h x"   . helpful-command)
         ("C-h F"   . helpful-function)
         ("C-c C-d" . helpful-at-point)))

(provide 'lf-completion)
;;; lf-completion.el ends here
