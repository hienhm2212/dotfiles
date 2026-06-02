;;; lf-lang-ruby.el --- Ruby/Rails language support -*- lexical-binding: t; -*-
;;; Commentary:
;; Ruby mode with eglot/solargraph, inf-ruby REPL, rspec-mode.
;; Prerequisites: gem install solargraph rubocop

;;; Code:

(use-package ruby-mode
  :ensure nil
  :mode ("\\.rb\\'"
         "Rakefile\\'"
         "Gemfile\\'")
  :interpreter "ruby"
  :custom
  (ruby-indent-level 2)
  (ruby-indent-tabs-mode nil)
  (ruby-deep-indent-paren nil)
  (ruby-deep-indent-paren-style nil)
  (ruby-after-operator-indent t)
  (ruby-method-params-indent 0)
  (ruby-block-indent t)
  :config
  (setq ruby-insert-encoding-magic-comment nil)
  (with-eval-after-load 'ruby-ts-mode
    (setq ruby-ts-mode-indent-offset 2)))

(use-package inf-ruby
  :ensure t
  :hook ((ruby-mode ruby-ts-mode) . inf-ruby-minor-mode)
  :bind (:map ruby-mode-map
              ("C-c C-s" . inf-ruby)
              ("C-c C-r" . ruby-send-region)
              ("C-c C-b" . ruby-send-buffer)))

(use-package rspec-mode
  :ensure t
  :defer t
  :hook ((ruby-mode ruby-ts-mode) . rspec-mode)
  :custom
  (rspec-use-relative-path t)
  (compilation-scroll-output t))

;; Eglot: ruby-lsp (faster startup than solargraph)
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((ruby-mode ruby-ts-mode) . ("ruby-lsp"))))

;; Ruby mode hooks
(add-hook 'ruby-mode-hook
          (lambda ()
            (setq-local tab-width 2)
            (setq-local indent-tabs-mode nil)
            (setq-local standard-indent 2)
            (setq-local electric-indent-chars
                        (append '(?. ?@ ?:) electric-indent-chars))))

(add-hook 'ruby-ts-mode-hook
          (lambda ()
            (setq-local tab-width 2)
            (setq-local indent-tabs-mode nil)
            (setq-local standard-indent 2)
            (setq-local electric-indent-chars
                        (append '(?. ?@ ?:) electric-indent-chars))))

(provide 'lf-lang-ruby)
;;; lf-lang-ruby.el ends here
