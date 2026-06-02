;;; lf-lang-web.el --- JavaScript/TypeScript/React support -*- lexical-binding: t; -*-
;;; Commentary:
;; JS/TS/JSX/TSX modes via tree-sitter, eglot + typescript-language-server,
;; add-node-modules-path, npm-mode, Prettier via Apheleia.
;; Prerequisites: npm install -g typescript-language-server typescript

;;; Code:

;; ── Project-local node_modules binaries ──────────────────────────

(use-package add-node-modules-path
  :ensure t
  :hook ((typescript-ts-mode . add-node-modules-path)
         (tsx-ts-mode        . add-node-modules-path)
         (js-ts-mode         . add-node-modules-path)
         (jsx-ts-mode        . add-node-modules-path)
         (json-ts-mode       . add-node-modules-path)))

;; ── npm-mode ──────────────────────────────────────────────────────

(use-package npm-mode
  :ensure t
  :hook ((typescript-ts-mode . npm-mode)
         (tsx-ts-mode        . npm-mode)
         (js-ts-mode         . npm-mode)
         (jsx-ts-mode        . npm-mode)))

;; ── JS/TS indent defaults ─────────────────────────────────────────

(setq js-indent-level 2)

;; ── TypeScript/TSX mode ───────────────────────────────────────────

(use-package typescript-ts-mode
  :ensure nil
  :custom
  (typescript-ts-mode-indent-offset 2)
  :hook
  ((typescript-ts-mode . (lambda ()
                           (setq-local fill-column 100)
                           (setq-local comment-multi-line t)))
   (tsx-ts-mode        . (lambda ()
                           (setq-local fill-column 100)
                           (setq-local comment-multi-line t)))))

(add-hook 'js-ts-mode-hook  (lambda () (setq-local js-indent-level 2)))
(add-hook 'jsx-ts-mode-hook (lambda () (setq-local js-indent-level 2)))

;; Ensure apheleia (prettier) is active in all JS/TS buffers
(dolist (hook '(typescript-ts-mode-hook tsx-ts-mode-hook
                js-ts-mode-hook jsx-ts-mode-hook))
  (add-hook hook #'apheleia-mode))

;; ── Eglot configuration for TypeScript ───────────────────────────

(with-eval-after-load 'eglot
  ;; Merge TS/JS workspace config (append so Go/Ruby configs survive)
  (setq-default eglot-workspace-configuration
                (append (default-value 'eglot-workspace-configuration)
                        '(:typescript
                          (:inlayHints
                           (:includeInlayParameterNameHints "none"
                            :includeInlayParameterNameHintsWhenArgumentMatchesName :json-false
                            :includeInlayFunctionParameterTypeHints :json-false
                            :includeInlayVariableTypeHints :json-false
                            :includeInlayPropertyDeclarationTypeHints :json-false
                            :includeInlayFunctionLikeReturnTypeHints :json-false
                            :includeInlayEnumMemberValueHints :json-false)
                           :suggest
                           (:includeCompletionsForModuleExports t
                            :includeCompletionsWithObjectLiteralMethodSnippets t
                            :includeAutomaticOptionalChainCompletions t)
                           :preferences
                           (:importModuleSpecifierPreference "shortest"
                            :quotePreference "single"))
                          :javascript
                          (:inlayHints
                           (:includeInlayParameterNameHints "none"
                            :includeInlayParameterNameHintsWhenArgumentMatchesName :json-false
                            :includeInlayFunctionParameterTypeHints :json-false
                            :includeInlayVariableTypeHints :json-false
                            :includeInlayPropertyDeclarationTypeHints :json-false
                            :includeInlayFunctionLikeReturnTypeHints :json-false
                            :includeInlayEnumMemberValueHints :json-false)
                           :suggest
                           (:includeCompletionsForModuleExports t
                            :includeAutomaticOptionalChainCompletions t)))))

  ;; Organize imports on save for TS/TSX
  (defun my-eglot-organize-imports ()
    "Organize imports in TypeScript/TSX buffers with eglot."
    (when (and (eglot-managed-p)
               (member major-mode '(typescript-ts-mode tsx-ts-mode)))
      (ignore-errors
        (eglot-code-action-organize-imports (point-min)))))

  (add-hook 'before-save-hook #'my-eglot-organize-imports))

(provide 'lf-lang-web)
;;; lf-lang-web.el ends here
