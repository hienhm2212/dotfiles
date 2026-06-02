;;; lf-prog.el --- Shared development tooling -*- lexical-binding: t; -*-
;;; Commentary:
;; Shared configuration for all programming modes: Eglot (LSP), Tree-sitter,
;; Apheleia (formatting), and common dev packages: projectile, magit, dired,
;; ace-window, avy, rg, multiple-cursors, markdown, yaml/json/csv, etc.

;;; Code:

;; ──────────────────────────────────────────────
;; Eglot (built-in LSP client)
;; ──────────────────────────────────────────────

(use-package eglot
  :ensure nil
  :defer t
  :custom
  (eglot-ignored-server-capabilities '(:documentHighlightProvider :inlayHintProvider))
  (eglot-connect-timeout 30)
  ;; Don't block the UI while LSP connects
  (eglot-sync-connect nil))

;; Speed up LSP JSON-RPC throughput (requires emacs-lsp-booster binary on PATH)
;; Install: cargo install emacs-lsp-booster
(use-package eglot-booster
  :ensure (:host github :repo "jdtsmith/eglot-booster")
  :after eglot
  :if (executable-find "emacs-lsp-booster")
  :config (eglot-booster-mode))

;; ──────────────────────────────────────────────
;; so-long-mode: degrade gracefully for large/minified files
;; ──────────────────────────────────────────────

(use-package so-long
  :ensure nil
  :config (global-so-long-mode 1))

;; ──────────────────────────────────────────────
;; Tree-sitter grammars and mode remapping
;; ──────────────────────────────────────────────

(use-package treesit
  :ensure nil
  :when (treesit-available-p)
  :mode (("\\.tsx\\'"        . tsx-ts-mode)
         ("\\.ts\\'"         . typescript-ts-mode)
         ("\\.mts\\'"        . typescript-ts-mode)
         ("\\.js\\'"         . js-ts-mode)
         ("\\.mjs\\'"        . js-ts-mode)
         ("\\.cjs\\'"        . js-ts-mode)
         ("\\.jsx\\'"        . jsx-ts-mode)
         ("\\.json\\'"       . json-ts-mode)
         ("\\.Dockerfile\\'" . dockerfile-ts-mode)
         ("\\.prisma\\'"     . prisma-ts-mode))
  :preface
  (defun lf/setup-install-grammars ()
    "Install Tree-sitter grammars if they are absent."
    (interactive)
    (dolist (grammar
             '((css        . ("https://github.com/tree-sitter/tree-sitter-css"        "v0.21.0" "src"))
               (bash       . ("https://github.com/tree-sitter/tree-sitter-bash"       "v0.21.0" "src"))
               (html       . ("https://github.com/tree-sitter/tree-sitter-html"       "v0.20.1" "src"))
               (javascript . ("https://github.com/tree-sitter/tree-sitter-javascript" "v0.21.2" "src"))
               (json       . ("https://github.com/tree-sitter/tree-sitter-json"       "v0.20.2" "src"))
               (python     . ("https://github.com/tree-sitter/tree-sitter-python"     "v0.21.0" "src"))
               (go         . ("https://github.com/tree-sitter/tree-sitter-go"         "v0.21.0" "src"))
               (gomod      . ("https://github.com/camdencheek/tree-sitter-go-mod"     "v1.0.2"  "src"))
               (markdown   . ("https://github.com/ikatyang/tree-sitter-markdown"      "v0.7.1"  "tree-sitter-markdown/src"))
               (make       . ("https://github.com/alemuller/tree-sitter-make"         "v1.0.0"  "src"))
               (elisp      . ("https://github.com/Wilfred/tree-sitter-elisp"          "v1.3.0"  "src"))
               (cmake      . ("https://github.com/uyha/tree-sitter-cmake"             "v0.5.0"  "src"))
               (c          . ("https://github.com/tree-sitter/tree-sitter-c"          "v0.21.3" "src"))
               (cpp        . ("https://github.com/tree-sitter/tree-sitter-cpp"        "v0.22.0" "src"))
               (toml       . ("https://github.com/tree-sitter/tree-sitter-toml"       "v0.5.1"  "src"))
               (ruby       . ("https://github.com/tree-sitter/tree-sitter-ruby"       "v0.21.0" "src"))
               (tsx        . ("https://github.com/tree-sitter/tree-sitter-typescript" "v0.21.2" "tsx/src"))
               (typescript . ("https://github.com/tree-sitter/tree-sitter-typescript" "v0.21.2" "typescript/src"))
               (yaml       . ("https://github.com/ikatyang/tree-sitter-yaml"          "v0.5.0"  "src"))
               (prisma     . ("https://github.com/victorhqc/tree-sitter-prisma"       "v1.4.0"  "src"))))
      (add-to-list 'treesit-language-source-alist grammar)
      (unless (treesit-language-available-p (car grammar))
        (message "Installing %s tree-sitter grammar..." (car grammar))
        (condition-case err
            (treesit-install-language-grammar (car grammar))
          (error (message "Failed to install %s: %s" (car grammar) err))))))
  :config
  (lf/setup-install-grammars)
  (dolist (mapping
           '((python-mode      . python-ts-mode)
             (css-mode         . css-ts-mode)
             (typescript-mode  . typescript-ts-mode)
             (js-mode          . js-ts-mode)
             (js2-mode         . js-ts-mode)
             (go-mode          . go-ts-mode)
             (c-mode           . c-ts-mode)
             (c++-mode         . c++-ts-mode)
             (c-or-c++-mode    . c-or-c++-ts-mode)
             (bash-mode        . bash-ts-mode)
             (json-mode        . json-ts-mode)
             (js-json-mode     . json-ts-mode)
             (sh-mode          . bash-ts-mode)
             (sh-base-mode     . bash-ts-mode)
             (ruby-mode        . ruby-ts-mode)))
    (add-to-list 'major-mode-remap-alist mapping)))

;; ──────────────────────────────────────────────
;; prog-mode shared hooks
;; ──────────────────────────────────────────────

(add-hook 'prog-mode-hook #'electric-pair-local-mode)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'prog-mode-hook #'show-paren-mode)
(add-hook 'prog-mode-hook #'subword-mode)
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
;; Defer LSP startup so file opens immediately; eglot connects after 1s idle
(add-hook 'prog-mode-hook (lambda ()
                            (when (mode-has-lsp-p)
                              (let ((buf (current-buffer)))
                                (run-with-idle-timer
                                 1 nil
                                 (lambda ()
                                   (when (buffer-live-p buf)
                                     (with-current-buffer buf
                                       (eglot-ensure)))))))))

;; ──────────────────────────────────────────────
;; Scope visibility
;; ──────────────────────────────────────────────

;; which-function-mode — show current function name in modeline
(which-function-mode 1)

;; breadcrumb — show scope path in header line (Function > Block > ...)
(use-package breadcrumb
  :ensure t
  :hook (prog-mode . breadcrumb-local-mode))

;; ──────────────────────────────────────────────
;; Apheleia (async code formatting on save)
;; ──────────────────────────────────────────────

(use-package apheleia
  :ensure t
  :defer t
  :custom
  (apheleia-formatters-respect-indent-level t)
  (apheleia-hide-log-buffers t)
  (apheleia-log-only-errors nil)
  (apheleia-remote-algorithm 'local)
  :config
  ;; C/C++
  (setf (alist-get 'clang-format apheleia-formatters) '("clang-format" "--assume-filename" filepath))
  (setf (alist-get 'c-mode       apheleia-mode-alist) 'clang-format)
  (setf (alist-get 'c++-mode     apheleia-mode-alist) 'clang-format)
  (setf (alist-get 'c-ts-mode    apheleia-mode-alist) 'clang-format)
  (setf (alist-get 'c++-ts-mode  apheleia-mode-alist) 'clang-format)
  (setf (alist-get 'objc-mode    apheleia-mode-alist) 'clang-format)
  ;; Rust
  (setf (alist-get 'rustfmt    apheleia-formatters) '("rustfmt" "--quiet" "--emit" "stdout"))
  (setf (alist-get 'rust-mode  apheleia-mode-alist) 'rustfmt)
  (setf (alist-get 'rust-ts-mode apheleia-mode-alist) 'rustfmt)
  (setf (alist-get 'rustic-mode  apheleia-mode-alist) 'rustfmt)
  ;; Go
  (setf (alist-get 'gofmt      apheleia-formatters) '("gofmt"))
  (setf (alist-get 'go-mode    apheleia-mode-alist) 'gofmt)
  (setf (alist-get 'go-ts-mode apheleia-mode-alist) 'gofmt)
  ;; Zig
  (setf (alist-get 'zigfmt       apheleia-formatters) '("zig" "fmt" "--stdin"))
  (setf (alist-get 'zig-mode     apheleia-mode-alist) 'zigfmt)
  (setf (alist-get 'zig-ts-mode  apheleia-mode-alist) 'zigfmt)
  ;; ESLint (definition only, Prettier used for auto-format)
  (setf (alist-get 'eslint apheleia-formatters)
        '("npx" "eslint" "--fix-to-stdout" "--stdin" "--stdin-filename" filepath))
  ;; Prettier
  (setf (alist-get 'prettier apheleia-formatters) '("prettier" "--stdin-filepath" filepath))
  (setf (alist-get 'javascript-mode      apheleia-mode-alist) 'prettier)
  (setf (alist-get 'js-mode              apheleia-mode-alist) 'prettier)
  (setf (alist-get 'js-ts-mode           apheleia-mode-alist) 'prettier)
  (setf (alist-get 'jsx-ts-mode          apheleia-mode-alist) 'prettier)
  (setf (alist-get 'js2-mode             apheleia-mode-alist) 'prettier)
  (setf (alist-get 'typescript-mode      apheleia-mode-alist) 'prettier)
  (setf (alist-get 'typescript-ts-mode   apheleia-mode-alist) 'prettier)
  (setf (alist-get 'tsx-ts-mode          apheleia-mode-alist) 'prettier)
  (setf (alist-get 'typescriptreact-mode apheleia-mode-alist) 'prettier)
  (setf (alist-get 'rjsx-mode            apheleia-mode-alist) 'prettier)
  (setf (alist-get 'json-mode            apheleia-mode-alist) 'prettier)
  (setf (alist-get 'json-ts-mode         apheleia-mode-alist) 'prettier)
  (setf (alist-get 'jsonc-mode           apheleia-mode-alist) 'prettier)
  (setf (alist-get 'html-mode            apheleia-mode-alist) 'prettier)
  (setf (alist-get 'html-ts-mode         apheleia-mode-alist) 'prettier)
  (setf (alist-get 'mhtml-mode           apheleia-mode-alist) 'prettier)
  (setf (alist-get 'web-mode             apheleia-mode-alist) 'prettier)
  (setf (alist-get 'xml-mode             apheleia-mode-alist) 'prettier)
  (setf (alist-get 'css-mode             apheleia-mode-alist) 'prettier)
  (setf (alist-get 'css-ts-mode          apheleia-mode-alist) 'prettier)
  (setf (alist-get 'scss-mode            apheleia-mode-alist) 'prettier)
  (setf (alist-get 'sass-mode            apheleia-mode-alist) 'prettier)
  (setf (alist-get 'less-css-mode        apheleia-mode-alist) 'prettier)
  (setf (alist-get 'yaml-mode            apheleia-mode-alist) 'prettier)
  (setf (alist-get 'yaml-ts-mode         apheleia-mode-alist) 'prettier)
  (setf (alist-get 'markdown-mode        apheleia-mode-alist) 'prettier)
  (setf (alist-get 'gfm-mode             apheleia-mode-alist) 'prettier)
  (setf (alist-get 'graphql-mode         apheleia-mode-alist) 'prettier)
  (setf (alist-get 'vue-mode             apheleia-mode-alist) 'prettier)
  (setf (alist-get 'svelte-mode          apheleia-mode-alist) 'prettier)
  (setf (alist-get 'astro-mode           apheleia-mode-alist) 'prettier)
  ;; Python — ruff
  (setf (alist-get 'ruff       apheleia-formatters) '("ruff" "format" "--silent" "--stdin-filename" filepath "-"))
  (setf (alist-get 'ruff-isort apheleia-formatters) '("ruff" "check" "--select" "I" "--fix" "--silent" "--stdin-filename" filepath "-"))
  (setf (alist-get 'python-mode    apheleia-mode-alist) '(ruff-isort ruff))
  (setf (alist-get 'python-ts-mode apheleia-mode-alist) '(ruff-isort ruff))
  ;; Haskell
  (setf (alist-get 'brittany   apheleia-formatters) '("brittany"))
  (setf (alist-get 'haskell-mode apheleia-mode-alist) 'brittany)
  ;; Elixir
  (setf (alist-get 'mix-format   apheleia-formatters) '("mix" "format" "-"))
  (setf (alist-get 'elixir-mode    apheleia-mode-alist) 'mix-format)
  (setf (alist-get 'elixir-ts-mode apheleia-mode-alist) 'mix-format)
  ;; OCaml
  (setf (alist-get 'ocamlformat apheleia-formatters)
        '("ocamlformat" "-" "--name" filepath "--enable-outside-detected-project"))
  (setf (alist-get 'caml-mode   apheleia-mode-alist) 'ocamlformat)
  (setf (alist-get 'tuareg-mode apheleia-mode-alist) 'ocamlformat)
  ;; Emacs Lisp
  (setf (alist-get 'lisp-indent    apheleia-formatters) '(apheleia-indent-lisp-buffer))
  (setf (alist-get 'emacs-lisp-mode apheleia-mode-alist) 'lisp-indent)
  (setf (alist-get 'lisp-mode       apheleia-mode-alist) 'lisp-indent)
  (setf (alist-get 'scheme-mode     apheleia-mode-alist) 'lisp-indent)
  ;; Java
  (setf (alist-get 'google-java-format apheleia-formatters) '("google-java-format" "-"))
  (setf (alist-get 'java-mode    apheleia-mode-alist) 'google-java-format)
  (setf (alist-get 'java-ts-mode apheleia-mode-alist) 'google-java-format)
  ;; Shell
  (setf (alist-get 'shfmt       apheleia-formatters) '("shfmt" "-i" "2" "-"))
  (setf (alist-get 'sh-mode     apheleia-mode-alist) 'shfmt)
  (setf (alist-get 'bash-ts-mode apheleia-mode-alist) 'shfmt)
  ;; Fish
  (setf (alist-get 'fish-indent apheleia-formatters) '("fish_indent"))
  (setf (alist-get 'fish-mode   apheleia-mode-alist) 'fish-indent)
  ;; Ruby — rubocop
  (setf (alist-get 'rubocop    apheleia-formatters)
        '("rubocop" "--stdin" filepath "--auto-correct" "--stderr" "--format" "quiet"))
  (setf (alist-get 'ruby-mode    apheleia-mode-alist) 'rubocop)
  (setf (alist-get 'ruby-ts-mode apheleia-mode-alist) 'rubocop)
  ;; Nix
  (setf (alist-get 'alejandra  apheleia-formatters) '("alejandra" "--quiet" "-"))
  (setf (alist-get 'nix-mode   apheleia-mode-alist) 'alejandra)
  (setf (alist-get 'nix-ts-mode apheleia-mode-alist) 'alejandra)
  ;; Terraform
  (setf (alist-get 'terraform      apheleia-formatters) '("terraform" "fmt" "-"))
  (setf (alist-get 'terraform-mode apheleia-mode-alist) 'terraform)
  ;; TOML
  (setf (alist-get 'taplo       apheleia-formatters) '("taplo" "fmt" "-"))
  (setf (alist-get 'toml-mode   apheleia-mode-alist) 'taplo)
  (setf (alist-get 'toml-ts-mode apheleia-mode-alist) 'taplo)
  ;; LaTeX
  (setf (alist-get 'latexindent  apheleia-formatters) '("latexindent" "--logfile=/dev/null"))
  (setf (alist-get 'latex-mode   apheleia-mode-alist) 'latexindent)
  (setf (alist-get 'LaTeX-mode   apheleia-mode-alist) 'latexindent)
  ;; PHP
  (setf (alist-get 'php-cs-fixer apheleia-formatters) '("php-cs-fixer" "--quiet" "fix" filepath))
  (setf (alist-get 'php-mode     apheleia-mode-alist) 'php-cs-fixer)
  ;; Lua
  (setf (alist-get 'stylua    apheleia-formatters) '("stylua" "-"))
  (setf (alist-get 'lua-mode  apheleia-mode-alist) 'stylua)
  ;; SQL — pg_format (install: sudo apt install pgformatter)
  (setf (alist-get 'pg_format apheleia-formatters) '("pg_format" "-" "-u" "0"))
  (setf (alist-get 'sql-mode  apheleia-mode-alist) 'pg_format)
  ;; Enable globally
  (apheleia-global-mode +1))

;; ──────────────────────────────────────────────
;; Eldoc
;; ──────────────────────────────────────────────

(use-package eldoc
  :ensure nil
  :custom
  (eldoc-help-at-pt 1)
  :init
  (global-eldoc-mode))

;; ──────────────────────────────────────────────
;; Dumb-jump (code navigation fallback)
;; ──────────────────────────────────────────────

(use-package dumb-jump
  :ensure t
  :defer t
  :init
  (setq dumb-jump-selector 'consult-completing-read)
  :bind (("M-g o" . dumb-jump-go-other-window)
         ("M-g j" . dumb-jump-go)
         ("M-g x" . dumb-jump-go-prefer-external)
         ("M-g z" . dumb-jump-go-prefer-external-other-window)
         ("M-g b" . dumb-jump-back))
  :config
  (setq dumb-jump-prefer-searcher 'rg
        xref-history-storage #'xref-window-local-history
        xref-show-definitions-function #'xref-show-definitions-completing-read)
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate)
  (remove-hook 'xref-backend-functions #'etags--xref-backend))

;; ──────────────────────────────────────────────
;; Projectile
;; ──────────────────────────────────────────────

(use-package projectile
  :ensure t
  :diminish projectile-mode
  :config
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (projectile-mode +1)
  (setq projectile-completion-system 'default
        projectile-enable-caching t
        projectile-indexing-method 'hybrid)
  (add-to-list 'projectile-globally-ignored-files "node_modules")
  (add-to-list 'projectile-globally-ignored-files ".cache")
  (add-to-list 'projectile-globally-ignored-files "_cache")
  (add-to-list 'projectile-globally-ignored-files "~")
  (add-to-list 'projectile-globally-ignored-files "#"))

(use-package makefile-executor
  :ensure t
  :defer t
  :config
  (add-hook 'makefile-mode-hook 'makefile-executor-mode))

(defun my-projectile-open-notes ()
  "Open notes.org in the current project root."
  (interactive)
  (find-file-other-window (expand-file-name "notes.org" (projectile-project-root))))

;; ──────────────────────────────────────────────
;; Magit
;; ──────────────────────────────────────────────

;; Emacs bundles an old transient; ensure elpaca installs the MELPA version
;; before magit loads (magit requires transient >= 0.12).
(use-package transient
  :ensure t)

(elpaca-wait)

(use-package magit
  :ensure t
  :hook (magit-mode . (lambda () (display-line-numbers-mode 0)))
  :bind (("C-x g" . magit-status)))

(use-package magit-todos
  :ensure t
  :after magit
  :config (magit-todos-mode 1))

;; ──────────────────────────────────────────────
;; Ibuffer
;; ──────────────────────────────────────────────

(use-package ibuffer
  :ensure nil
  :config
  (setq ibuffer-expert t
        ibuffer-display-summary nil
        ibuffer-use-other-window nil
        ibuffer-show-empty-filter-groups nil
        ibuffer-default-sorting-mode 'filename/process
        ibuffer-title-face 'font-lock-doc-face
        ibuffer-use-header-line t
        ibuffer-default-shrink-to-minimum-size nil
        ibuffer-formats
        '((mark modified read-only locked " "
                (name 30 30 :left :elide) " "
                (size 9 -1 :right) " "
                (mode 16 16 :left :elide) " " filename-and-process)
          (mark " " (name 16 -1) " " filename))
        ibuffer-saved-filter-groups
        '(("Main"
           ("Directories" (mode . dired-mode))
           ("Ruby"    (or (mode . ruby-mode) (mode . ruby-ts-mode)))
           ("Golang"  (or (mode . go-mode) (mode . go-ts-mode)))
           ("C++"     (or (mode . c++-mode) (mode . c++-ts-mode)
                          (mode . c-mode) (mode . c-ts-mode) (mode . c-or-c++-ts-mode)))
           ("Python"  (or (mode . python-ts-mode) (mode . python-mode)))
           ("Build"   (or (mode . make-mode) (mode . makefile-gmake-mode)
                          (name . "^Makefile$") (mode . change-log-mode)))
           ("Scripts" (or (mode . shell-script-mode) (mode . shell-mode)
                          (mode . sh-mode) (mode . lua-mode) (mode . bat-mode)))
           ("Config"  (or (mode . conf-mode) (mode . conf-toml-mode)
                          (mode . toml-ts-mode) (mode . conf-windows-mode)
                          (name . "^\\.clangd$") (name . "^\\.gitignore$")
                          (name . "^Doxyfile$") (name . "^config\\.toml$")
                          (mode . yaml-mode)))
           ("Web"     (or (mode . mhtml-mode) (mode . html-mode)
                          (mode . web-mode) (mode . nxml-mode)))
           ("CSS"     (or (mode . css-mode) (mode . sass-mode)))
           ("JS"      (or (mode . js-mode) (mode . rjsx-mode)))
           ("Markup"  (or (mode . markdown-mode) (mode . adoc-mode)))
           ("Org"     (mode . org-mode))
           ("LaTeX"   (name . "\.tex$"))
           ("Magit"   (or (mode . magit-blame-mode) (mode . magit-cherry-mode)
                          (mode . magit-diff-mode) (mode . magit-log-mode)
                          (mode . magit-process-mode) (mode . magit-status-mode)))
           ("Apps"    (or (mode . elfeed-search-mode) (mode . elfeed-show-mode)))
           ("Fundamental" (or (mode . fundamental-mode) (mode . text-mode)))
           ("Tramp"   (name . "^\\*tramp.*"))
           ("Emacs"   (or (mode . emacs-lisp-mode)
                          (name . "^\\*Help\\*$")
                          (name . "^\\*Custom.*")
                          (name . "^\\*Org Agenda\\*$")
                          (name . "^\\*info\\*$")
                          (name . "^\\*scratch\\*$")
                          (name . "^\\*Backtrace\\*$")
                          (name . "^\\*Messages\\*$"))))))
  :hook (ibuffer-mode . (lambda ()
                          (ibuffer-switch-to-saved-filter-groups "Main"))))

;; ──────────────────────────────────────────────
;; Dired
;; ──────────────────────────────────────────────

(use-package dired
  :ensure nil
  :bind (("M-i" . emacs-solo/window-dired-vc-root-left))
  :custom
  (dired-dwim-target t)
  (dired-guess-shell-alist-user
   '(("\\.\\(png\\|jpe?g\\|tiff\\)" "feh" "xdg-open" "open")
     ("\\.\\(mp[34]\\|m4a\\|ogg\\|flac\\|webm\\|mkv\\)" "mpv" "xdg-open" "open")
     (".*" "xdg-open" "open")))
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-listing-switches "-alh --group-directories-first")
  (dired-omit-files "^\\.")
  (dired-recursive-copies 'always)
  (dired-recursive-deletes 'always)
  :init
  (add-hook 'dired-mode-hook (lambda () (dired-omit-mode 1)))

  (defun emacs-solo/dired-rsync-copy (dest)
    "Copy marked Dired files to DEST using rsync asynchronously."
    (interactive
     (list (expand-file-name (read-file-name "rsync to: " (dired-dwim-target-directory)))))
    (let* ((files (dired-get-marked-files nil current-prefix-arg))
           (dest-rsync
            (if (file-remote-p dest)
                (let* ((vec  (tramp-dissect-file-name dest))
                       (user (tramp-file-name-user vec))
                       (host (tramp-file-name-host vec))
                       (path (tramp-file-name-localname vec)))
                  (concat (if user (concat user "@") "") host ":" path))
              dest))
           (files-rsync
            (mapcar (lambda (f)
                      (if (file-remote-p f)
                          (let* ((vec  (tramp-dissect-file-name f))
                                 (user (tramp-file-name-user vec))
                                 (host (tramp-file-name-host vec))
                                 (path (tramp-file-name-localname vec)))
                            (concat (if user (concat user "@") "") host ":" path))
                        f))
                    files))
           (command (append '("rsync" "-hPur") files-rsync (list dest-rsync)))
           (buffer  (get-buffer-create "*rsync*")))
      (with-current-buffer buffer (erase-buffer) (insert "Running rsync...\n"))
      (make-process
       :name "dired-rsync" :buffer buffer :command command
       :filter (lambda (proc string)
                 (with-current-buffer (process-buffer proc)
                   (goto-char (point-max))
                   (insert string)
                   (goto-char (point-max))
                   (while (re-search-backward "\r" nil t) (replace-match "\n" nil nil))))
       :sentinel (lambda (_proc event)
                   (when (string-match-p "finished" event)
                     (with-current-buffer buffer (goto-char (point-max)) (insert "\n* rsync done *\n"))
                     (dired-revert)))
       :stderr buffer)
      (display-buffer buffer)
      (message "rsync started...")))

  (defun emacs-solo/window-dired-vc-root-left (&optional directory-path)
    "Open a side Dired window at VC root (or current dir)."
    (interactive)
    (add-hook 'dired-mode-hook 'dired-hide-details-mode)
    (let ((dir (if directory-path
                   (dired-noselect directory-path)
                 (if (eq (vc-root-dir) nil)
                     (dired-noselect default-directory)
                   (dired-noselect (vc-root-dir))))))
      (display-buffer-in-side-window
       dir `((side . left) (slot . 0) (window-width . 30)
              (window-parameters . ((no-other-window . t)
                                    (no-delete-other-windows . t)
                                    (mode-line-format . (" " "%b"))))))
      (with-current-buffer dir
        (when-let ((window (get-buffer-window dir)))
          (select-window window)
          (rename-buffer "*Dired-Side*")))))

  (defun emacs-solo/window-dired-open-directory ()
    "Open the current Dired entry in the side window."
    (interactive)
    (emacs-solo/window-dired-vc-root-left (dired-get-file-for-visit)))

  (defun emacs-solo/window-dired-open-directory-back ()
    "Navigate to parent directory in the side window."
    (interactive)
    (emacs-solo/window-dired-vc-root-left "../")
    (when (get-buffer "*Dired-Side*")
      (with-current-buffer "*Dired-Side*" (revert-buffer t t))))

  (eval-after-load 'dired
    '(progn
       (define-key dired-mode-map (kbd "=") 'emacs-solo/window-dired-open-directory)
       (define-key dired-mode-map (kbd "-") 'emacs-solo/window-dired-open-directory-back)
       (define-key dired-mode-map (kbd "b") 'dired-up-directory))))

(use-package wdired
  :ensure nil
  :commands (wdired-change-to-wdired-mode)
  :config
  (setq wdired-allow-to-change-permissions t
        wdired-create-parent-directories t))

;; ──────────────────────────────────────────────
;; Dirvish — modern Dired UI
;; ──────────────────────────────────────────────

(use-package dirvish
  :ensure t
  :init
  (dirvish-override-dired-mode)
  :custom
  (dirvish-quick-access-entries
   '(("h" "~/"          "Home")
     ("d" "~/Downloads" "Downloads")
     ("p" "~/projects"  "Projects")
     ("o" "~/org"       "Org")))
  (dirvish-attributes '(nerd-icons file-time file-size collapse subtree-state vc-state git-msg))
  (dirvish-subtree-state-style 'nerd)
  (dirvish-side-width 35)
  (dirvish-default-layout '(0 0.4 0.6))
  :config
  (setq dired-listing-switches "-l --almost-all --human-readable --group-directories-first --no-group")
  :bind
  (("C-c f"   . dirvish-fd)
   :map dirvish-mode-map
   ("a"        . dirvish-quick-access)
   ("f"        . dirvish-file-info-menu)
   ("y"        . dirvish-yank-menu)
   ("N"        . dirvish-narrow)
   ("^"        . dirvish-history-last)
   ("s"        . dirvish-quicksort)
   ("v"        . dirvish-vc-menu)
   ("TAB"      . dirvish-subtree-toggle)
   ("M-f"      . dirvish-history-go-forward)
   ("M-b"      . dirvish-history-go-backward)
   ("M-l"      . dirvish-ls-switches-menu)
   ("M-m"      . dirvish-mark-menu)
   ("M-t"      . dirvish-layout-toggle)
   ("M-s"      . dirvish-setup-menu)
   ("M-e"      . dirvish-emerge-menu)
   ("M-j"      . dirvish-fd-jump)))

;; ──────────────────────────────────────────────
;; ace-window
;; ──────────────────────────────────────────────

(use-package ace-window
  :ensure t
  :defer t
  :init
  (global-set-key [remap other-window] 'ace-window)
  :custom
  (aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  (aw-background nil))

;; ──────────────────────────────────────────────
;; avy
;; ──────────────────────────────────────────────

(use-package avy
  :ensure t
  :bind (("M-j" . avy-goto-char-timer)
         :map isearch-mode-map
         ("M-j" . avy-isearch)))

;; ──────────────────────────────────────────────
;; ripgrep
;; ──────────────────────────────────────────────

(use-package rg
  :ensure t
  :commands (rg-menu))

;; ──────────────────────────────────────────────
;; expand-region — semantic selection expansion
;; ──────────────────────────────────────────────

(use-package expand-region
  :ensure t
  :bind (("C-=" . er/expand-region)
         ("C--" . er/contract-region)))

;; ──────────────────────────────────────────────
;; multiple-cursors
;; ──────────────────────────────────────────────

(use-package multiple-cursors
  :ensure t
  :bind (("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)))

;; ──────────────────────────────────────────────
;; Markdown
;; ──────────────────────────────────────────────

(use-package markdown-mode
  :ensure t
  :mode (("\\.md\\'"       . gfm-mode)
         ("\\.markdown\\'" . gfm-mode))
  :custom
  (markdown-fontify-code-blocks-natively t)
  (markdown-command "pandoc")
  (markdown-enable-math t)
  (markdown-code-lang-modes
   '(("elisp"      . emacs-lisp-mode)
     ("emacs-lisp" . emacs-lisp-mode)
     ("shell"      . sh-mode)
     ("bash"       . sh-mode)
     ("sh"         . sh-mode)
     ("javascript" . js-ts-mode)
     ("js"         . js-ts-mode)
     ("typescript" . typescript-ts-mode)
     ("ts"         . typescript-ts-mode)
     ("tsx"        . tsx-ts-mode)
     ("jsx"        . jsx-ts-mode)
     ("python"     . python-ts-mode)
     ("py"         . python-ts-mode)
     ("go"         . go-ts-mode)
     ("ruby"       . ruby-ts-mode)
     ("rb"         . ruby-ts-mode)
     ("rust"       . rust-mode)
     ("css"        . css-ts-mode)
     ("json"       . json-ts-mode)
     ("yaml"       . yaml-ts-mode)
     ("sql"        . sql-mode)
     ("html"       . html-mode))))

;; ──────────────────────────────────────────────
;; YAML / JSON / CSV / Lua / Conf modes
;; ──────────────────────────────────────────────

(use-package yaml-mode :ensure t)
(use-package json-mode :ensure t)
(use-package csv-mode  :ensure t)
(use-package lua-mode  :ensure t :custom (lua-indent-level 2))

(use-package conf-mode
  :ensure nil
  :mode ("\\.env\\..*\\'" "\\.env\\'")
  :init
  (add-to-list 'auto-mode-alist '("\\.env\\'" . conf-mode)))

;; ──────────────────────────────────────────────
;; CSS
;; ──────────────────────────────────────────────

(use-package css-mode
  :ensure nil
  :custom (css-indent-offset 2))

;; ──────────────────────────────────────────────
;; jinx — fast spell checking
;; ──────────────────────────────────────────────

(use-package jinx
  :ensure t
  :hook (emacs-startup . global-jinx-mode)
  :bind (("M-$"   . jinx-correct)
         ("C-M-$" . jinx-languages)))

;; ──────────────────────────────────────────────
;; hl-todo — highlight TODO/FIXME/HACK keywords
;; ──────────────────────────────────────────────

(use-package hl-todo
  :ensure t
  :config
  (global-hl-todo-mode 1))

;; ──────────────────────────────────────────────
;; git-timemachine — walk file git history
;; ──────────────────────────────────────────────

(use-package git-timemachine
  :ensure t
  :bind ("C-c g t" . git-timemachine))

;; ──────────────────────────────────────────────
;; popper — manage popup buffers
;; ──────────────────────────────────────────────

(use-package popper
  :ensure t
  :bind (("C-`"   . popper-toggle)
         ("M-`"   . popper-cycle)
         ("C-M-`" . popper-toggle-type))
  :custom
  (popper-reference-buffers
   '("\\*Messages\\*"
     "\\*Warnings\\*"
     "\\*Backtrace\\*"
     "\\*Compile-Log\\*"
     "\\*compilation\\*"
     "\\*rg\\*"
     "\\*eshell\\*"
     help-mode
     compilation-mode))
  :config
  (popper-mode 1)
  (popper-echo-mode 1))

;; ──────────────────────────────────────────────
;; arrow — per-project and buffer-local bookmarks
;; ──────────────────────────────────────────────
;; Three bookmark layers: buffer (line positions), project (files), global.
;; Visual fringe markers show bookmarked lines at a glance.

(use-package arrow
  :ensure (:host github :repo "vmargb/arrow.el")
  :defer t
  :custom
  (arrow-persist t)
  (arrow-visual-marker t)
  (arrow-visual-marker-position 'left)
  :bind (("C-c b a" . arrow-add)
         ("C-c b s" . arrow-show)
         ("C-c b n" . arrow-next-line)
         ("C-c b p" . arrow-prev-line)
         ("C-c b j" . arrow-jump)
         ("C-c b P" . arrow-project-add)
         ("C-c b N" . arrow-project-next)
         ("C-c b v" . arrow-project-prev)))

(provide 'lf-prog)
;;; lf-prog.el ends here
