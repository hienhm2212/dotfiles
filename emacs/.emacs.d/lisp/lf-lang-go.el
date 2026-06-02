;;; lf-lang-go.el --- Go language support -*- lexical-binding: t; -*-
;;; Commentary:
;; Go mode with eglot/gopls, goimports on save, godoctor, go-tag.
;; Prerequisites: go install golang.org/x/tools/gopls@latest
;;               go install github.com/fatih/gomodifytags@latest

;;; Code:

(defun my-go-before-save ()
  "Format buffer and organize imports for Go files."
  (when (and (eglot-managed-p)
             (derived-mode-p 'go-mode 'go-ts-mode))
    (eglot-format-buffer)
    (ignore-errors
      (eglot-code-action-organize-imports (point-min)))))

(use-package go-mode
  :ensure t
  :mode "\\.go\\'"
  :custom
  (go-ts-mode-indent-offset 4)
  :bind (:map go-mode-map
              ("C-c C-d" . godoc-at-point)
              ("C-c C-a" . go-import-add)
              ("C-c C-r" . go-remove-unused-imports))
  :hook
  ((go-mode go-ts-mode) . (lambda ()
                            (setq-local indent-tabs-mode t)
                            (setq-local tab-width 4)
                            (add-hook 'before-save-hook #'my-go-before-save -10 t))))

;; gopls workspace configuration
(with-eval-after-load 'eglot
  (setq-default eglot-workspace-configuration
                (append (default-value 'eglot-workspace-configuration)
                        '(:gopls
                          (:usePlaceholders t
                           :staticcheck t
                           :gofumpt :json-false
                           :analyses (:unusedparams t
                                      :shadow t
                                      :unusedwrite t)
                           :hints (:parameterNames t
                                   :constantValues t
                                   :compositeLiteralTypes t))))))

(use-package godoctor
  :ensure t
  :defer t
  :after go-mode)

(use-package go-tag
  :ensure t
  :defer t
  :after go-mode)

(provide 'lf-lang-go)
;;; lf-lang-go.el ends here
