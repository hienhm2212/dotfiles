;;; lf-shell.el --- Eshell with custom prompt and history -*- lexical-binding: t; -*-
;;; Commentary:
;; Full eshell configuration: custom powerline-style prompt with git branch,
;; merged history across sessions, syntax-highlighted cat, and local bindings.

;;; Code:

(defcustom emacs-solo-enabled-icons
  '(dired eshell ibuffer)
  "List of Emacs Solo icon features that are enabled."
  :type '(set :tag "Enabled Emacs Solo icon features"
              (const :tag "Dired Icons" dired)
              (const :tag "Eshell Icons" eshell)
              (const :tag "Ibuffer Icons" ibuffer)
              (const :tag "Nerd Font Icons" nerd))
  :group 'emacs-solo)

(defcustom emacs-solo-use-custom-theme 'crafters
  "Select which `emacs-solo` customization theme to use."
  :type '(choice
          (const :tag "Disabled" nil)
          (const :tag "Catppuccin" catppuccin)
          (const :tag "Crafters" crafters))
  :group 'emacs-solo)

(use-package eshell
  :ensure nil
  :bind (("C-c e" . eshell))
  :defer t
  :config
  (setq eshell-history-size 100000)
  (setq eshell-hist-ignoredups t)

  ;; ── Merge history across all eshell sessions ──────────────────────

  (defun emacs-solo/eshell--collect-all-history ()
    "Return a list of all eshell history entries from all buffers and disk."
    (let ((history-from-buffers
           (cl-loop for buf in (buffer-list)
                    when (with-current-buffer buf (derived-mode-p 'eshell-mode))
                    append (with-current-buffer buf
                             (when (boundp 'eshell-history-ring)
                               (ring-elements eshell-history-ring)))))
          (history-from-file
           (when (file-exists-p eshell-history-file-name)
             (with-temp-buffer
               (insert-file-contents eshell-history-file-name)
               (split-string (buffer-string) "\n" t)))))
      (seq-uniq (append history-from-buffers history-from-file))))

  (defun emacs-solo/eshell--save-merged-history ()
    "Save all eshell buffer histories merged into `eshell-history-file-name`."
    (let ((all-history (emacs-solo/eshell--collect-all-history)))
      (with-temp-file eshell-history-file-name
        (insert (mapconcat #'identity all-history "\n")))))

  (add-hook 'kill-emacs-hook #'emacs-solo/eshell--save-merged-history)
  (add-hook 'eshell-mode-hook (lambda () (eshell-read-history)))

  ;; ── Banner ────────────────────────────────────────────────────────

  (setopt eshell-banner-message
          (concat
           (propertize "   Welcome to the Emacs Solo Shell  \n\n" 'face '(:weight bold :foreground "#f9e2af"))
           (propertize " C-c t" 'face '(:foreground "#89b4fa" :weight bold)) " - toggles between prompts (full / minimum)\n"
           (propertize " C-c T" 'face '(:foreground "#89b4fa" :weight bold)) " - toggles between full prompts (lighter / heavier)\n"
           (propertize " C-c l" 'face '(:foreground "#89b4fa" :weight bold)) " - searches history\n"
           (propertize " C-l  " 'face '(:foreground "#89b4fa" :weight bold)) " - clears scrolling\n\n"))

  ;; ── Scrolling ─────────────────────────────────────────────────────

  (defun emacs-solo/reset-scrolling-vars-for-term ()
    "Locally reset scrolling behavior in term-like buffers."
    (setq-local scroll-conservatively 0)
    (setq-local scroll-margin 0))
  (add-hook 'eshell-mode-hook #'emacs-solo/reset-scrolling-vars-for-term)

  ;; ── History picker ────────────────────────────────────────────────

  (defun emacs-solo/eshell-pick-history ()
    "Show a unified and unique Eshell history from all open sessions and file."
    (interactive)
    (unless (derived-mode-p 'eshell-mode)
      (user-error "This command must be called from an Eshell buffer"))
    (let* ((bol (save-excursion (eshell-bol) (point)))
           (eol (point))
           (current-input (buffer-substring-no-properties bol eol))
           (history-file (expand-file-name eshell-history-file-name eshell-directory-name))
           (history-from-file
            (when (file-exists-p history-file)
              (with-temp-buffer
                (insert-file-contents-literally history-file)
                (split-string (buffer-string) "\n" t))))
           (history-from-rings
            (cl-loop for buf in (buffer-list)
                     when (with-current-buffer buf (derived-mode-p 'eshell-mode))
                     append (with-current-buffer buf
                              (when (bound-and-true-p eshell-history-ring)
                                (ring-elements eshell-history-ring)))))
           (all-history (reverse
                         (seq-uniq
                          (seq-filter (lambda (s) (and s (not (string-empty-p s))))
                                      (append history-from-rings history-from-file)))))
           (selection (completing-read "Eshell History: " all-history nil t current-input)))
      (when selection
        (delete-region bol eol)
        (insert selection))))

  ;; ── Syntax-highlighted cat ────────────────────────────────────────

  (defun eshell/cat-with-syntax-highlighting (filename)
    "Like cat(1) but with syntax highlighting."
    (let ((existing-buffer (get-file-buffer filename))
          (buffer (find-file-noselect filename)))
      (eshell-print
       (with-current-buffer buffer
         (if (fboundp 'font-lock-ensure)
             (font-lock-ensure)
           (with-no-warnings (font-lock-fontify-buffer)))
         (let ((contents (buffer-string)))
           (remove-text-properties 0 (length contents) '(read-only nil) contents)
           contents)))
      (unless existing-buffer (kill-buffer buffer))
      nil))
  (advice-add 'eshell/cat :override #'eshell/cat-with-syntax-highlighting)

  ;; ── Local keybindings ─────────────────────────────────────────────

  (add-hook 'eshell-mode-hook
            (lambda ()
              (local-set-key (kbd "C-c l") #'emacs-solo/eshell-pick-history)
              (local-set-key (kbd "C-c t") #'emacs-solo/toggle-eshell-prompt)
              (local-set-key (kbd "C-c T") #'emacs-solo/toggle-eshell-prompt-resource-intensive)
              (local-set-key (kbd "C-l")
                             (lambda ()
                               (interactive)
                               (eshell/clear 1)))))

  ;; ── Custom prompt ─────────────────────────────────────────────────

  (require 'vc)
  (require 'vc-git)

  (defvar emacs-solo/eshell-full-prompt t
    "When non-nil, show the full Eshell prompt.")

  (defvar emacs-solo/eshell-full-prompt-resource-intensive nil
    "When non-nil, show slower git status info in prompt.")

  (defvar emacs-solo/eshell-lambda-symbol "  λ "
    "Symbol used for the minimal Eshell prompt.")

  (defun emacs-solo/toggle-eshell-prompt ()
    "Toggle between full and minimal Eshell prompt."
    (interactive)
    (setq emacs-solo/eshell-full-prompt (not emacs-solo/eshell-full-prompt))
    (message "Eshell prompt: %s" (if emacs-solo/eshell-full-prompt "full" "minimal"))
    (when (derived-mode-p 'eshell-mode) (eshell-reset)))

  (defun emacs-solo/toggle-eshell-prompt-resource-intensive ()
    "Toggle resource-intensive git info in full prompt."
    (interactive)
    (setq emacs-solo/eshell-full-prompt-resource-intensive
          (not emacs-solo/eshell-full-prompt-resource-intensive))
    (message "Eshell prompt: %s"
             (if emacs-solo/eshell-full-prompt-resource-intensive "heavier" "lighter"))
    (when (derived-mode-p 'eshell-mode) (eshell-reset)))

  (defun enabled-icons-p ()
    "Return 'emoji, 'nerd or nil depending on `emacs-solo-enabled-icons`."
    (cond
     ((memq 'nerd emacs-solo-enabled-icons) 'nerd)
     ((memq 'eshell emacs-solo-enabled-icons) 'emoji)
     (t nil)))

  ;; Color palette (crafters / catppuccin)
  (unless (eq emacs-solo-use-custom-theme 'catppuccin)
    (defvar eshell-solo/color-bg-dark "#212234")
    (defvar eshell-solo/color-bg-mid "#45475A")
    (defvar eshell-solo/color-fg-user "#89b4fa")
    (defvar eshell-solo/color-fg-host "#b4befe")
    (defvar eshell-solo/color-fg-dir "#A6E3A1")
    (defvar eshell-solo/color-fg-git "#F9E2AF"))

  (when (eq emacs-solo-use-custom-theme 'catppuccin)
    (defvar eshell-solo/color-bg-dark "#363a4f")
    (defvar eshell-solo/color-bg-mid  "#494d64")
    (defvar eshell-solo/color-fg-user "#89b4fa")
    (defvar eshell-solo/color-fg-host "#b4befe")
    (defvar eshell-solo/color-fg-dir  "#a6e3a1")
    (defvar eshell-solo/color-fg-git  "#f9e2af"))

  ;; Icon sets
  (when (not (enabled-icons-p))
    (defvar emacs-solo/eshell-icons
      '((arrow-left . "") (arrow-right . "") (success . "『") (failure . "『")
        (user-local . "") (user-remote . "") (host-local . "") (host-remote . "")
        (time . "") (folder . "") (branch . " Git:") (modified . "M")
        (untracked . "U") (conflict . "X") (git-merge . "M") (git-ahead . "A") (git-behind . "B"))))

  (when (eq (enabled-icons-p) 'emoji)
    (defvar emacs-solo/eshell-icons
      '((arrow-left . "") (arrow-right . "") (success . "🟢") (failure . "🔴")
        (user-local . "🧙") (user-remote . "👽") (host-local . "💻") (host-remote . "🌐")
        (time . "🕒") (folder . "📁") (branch . "") (modified . "✏️")
        (untracked . "✨") (conflict . "⚔️") (git-merge . "🔀") (git-ahead . "⬆️") (git-behind . "⬇️"))))

  (when (eq (enabled-icons-p) 'nerd)
    (defvar emacs-solo/eshell-icons
      '((arrow-left . "") (arrow-right . "") (success . "") (failure . "")
        (user-local . "") (user-remote . "") (host-local . "") (host-remote . "")
        (time . "") (folder . "") (branch . "") (modified . "")
        (untracked . "") (conflict . "") (git-merge . "") (git-ahead . "") (git-behind . ""))))

  (setopt eshell-prompt-function
          (lambda ()
            (if emacs-solo/eshell-full-prompt
                (concat
                 (propertize (assoc-default 'arrow-left emacs-solo/eshell-icons) 'face `(:foreground ,eshell-solo/color-bg-dark))
                 (propertize (if (> eshell-last-command-status 0)
                                 (concat " " (assoc-default 'failure emacs-solo/eshell-icons) " ")
                               (concat " " (assoc-default 'success emacs-solo/eshell-icons) " "))
                             'face `(:background ,eshell-solo/color-bg-dark))
                 (propertize (concat (number-to-string eshell-last-command-status) " ")
                             'face `(:background ,eshell-solo/color-bg-dark))
                 (propertize (assoc-default 'arrow-right emacs-solo/eshell-icons)
                             'face `(:foreground ,eshell-solo/color-bg-dark :background ,eshell-solo/color-bg-mid))
                 (propertize (let ((remote-user (file-remote-p default-directory 'user))
                                   (is-remote (file-remote-p default-directory)))
                               (concat
                                (if is-remote
                                    (concat (assoc-default 'user-remote emacs-solo/eshell-icons) " ")
                                  (concat (assoc-default 'user-local emacs-solo/eshell-icons) " "))
                                (or remote-user (user-login-name)) " "))
                             'face `(:foreground ,eshell-solo/color-fg-user :background ,eshell-solo/color-bg-mid))
                 (propertize (assoc-default 'arrow-right emacs-solo/eshell-icons)
                             'face `(:foreground ,eshell-solo/color-bg-mid :background ,eshell-solo/color-bg-dark))
                 (let ((remote-host (file-remote-p default-directory 'host))
                       (is-remote (file-remote-p default-directory)))
                   (propertize (concat (if is-remote
                                           (concat " " (assoc-default 'host-remote emacs-solo/eshell-icons) " ")
                                         (concat " " (assoc-default 'host-local emacs-solo/eshell-icons) " "))
                                       (or remote-host (system-name)) " ")
                               'face `(:background ,eshell-solo/color-bg-dark :foreground ,eshell-solo/color-fg-host)))
                 (propertize (assoc-default 'arrow-right emacs-solo/eshell-icons)
                             'face `(:foreground ,eshell-solo/color-bg-dark :background ,eshell-solo/color-bg-mid))
                 (propertize (concat " " (assoc-default 'time emacs-solo/eshell-icons) " "
                                     (format-time-string "%H:%M:%S" (current-time)) " ")
                             'face `(:foreground ,eshell-solo/color-fg-user :background ,eshell-solo/color-bg-mid))
                 (propertize (assoc-default 'arrow-right emacs-solo/eshell-icons)
                             'face `(:foreground ,eshell-solo/color-bg-mid :background ,eshell-solo/color-bg-dark))
                 (propertize (concat " " (assoc-default 'folder emacs-solo/eshell-icons) " "
                                     (if (>= (length (eshell/pwd)) 40)
                                         (concat "…" (car (last (butlast (split-string (eshell/pwd) "/") 0))))
                                       (abbreviate-file-name (eshell/pwd))) " ")
                             'face `(:background ,eshell-solo/color-bg-dark :foreground ,eshell-solo/color-fg-dir))
                 (propertize (concat (assoc-default 'arrow-right emacs-solo/eshell-icons) "\n")
                             'face `(:foreground ,eshell-solo/color-bg-dark))
                 (when (and (fboundp 'vc-git-root) (vc-git-root default-directory))
                   (concat
                    (propertize (assoc-default 'arrow-left emacs-solo/eshell-icons)
                                'face `(:foreground ,eshell-solo/color-bg-dark))
                    (propertize
                     (concat
                      (concat " " (assoc-default 'branch emacs-solo/eshell-icons) " ")
                      (car (vc-git-branches))
                      (when emacs-solo/eshell-full-prompt-resource-intensive
                        (let* ((branch (car (vc-git-branches)))
                               (behind (string-to-number
                                        (shell-command-to-string
                                         (format "git rev-list --count origin/%s..HEAD" branch))))
                               (ahead (string-to-number
                                       (shell-command-to-string
                                        (format "git rev-list --count HEAD..origin/%s" branch)))))
                          (concat
                           (when (> ahead 0) (format (concat " " (assoc-default 'git-ahead emacs-solo/eshell-icons) "%d") ahead))
                           (when (> behind 0) (format (concat " " (assoc-default 'git-behind emacs-solo/eshell-icons) "%d") behind))
                           (when (and (> ahead 0) (> behind 0))
                             (concat "  " (assoc-default 'git-merge emacs-solo/eshell-icons)))))
                        (let ((modified (length (split-string (shell-command-to-string "git ls-files --modified") "\n" t)))
                              (untracked (length (split-string (shell-command-to-string "git ls-files --others --exclude-standard") "\n" t)))
                              (conflicts (length (split-string (shell-command-to-string "git diff --name-only --diff-filter=U") "\n" t))))
                          (concat
                           (if (> modified 0) (format (concat " " (assoc-default 'modified emacs-solo/eshell-icons) "%d") modified))
                           (if (> untracked 0) (format (concat " " (assoc-default 'untracked emacs-solo/eshell-icons) "%d") untracked))
                           (if (> conflicts 0) (format (concat " " (assoc-default 'conflict emacs-solo/eshell-icons) "%d") conflicts)))))
                      " ")
                     'face `(:background ,eshell-solo/color-bg-dark :foreground ,eshell-solo/color-fg-git))
                    (propertize (concat (assoc-default 'arrow-right emacs-solo/eshell-icons) "\n")
                                'face `(:foreground ,eshell-solo/color-bg-dark))))
                 (propertize emacs-solo/eshell-lambda-symbol 'face font-lock-keyword-face))
              (propertize emacs-solo/eshell-lambda-symbol 'face font-lock-keyword-face))))

  (setq eshell-prompt-regexp emacs-solo/eshell-lambda-symbol)

  ;; ── TERM env and visual commands ─────────────────────────────────

  (add-hook 'eshell-mode-hook (lambda () (setenv "TERM" "xterm-256color")))

  (with-eval-after-load 'em-term
    (add-to-list 'eshell-visual-subcommands '("jj" "resolve"))
    (add-to-list 'eshell-visual-subcommands '("jj" "squash")))

  (setq eshell-visual-commands
        '("vi" "screen" "top" "htop" "btm" "less" "more" "lynx" "ncftp" "pine" "tin" "trn"
          "elm" "irssi" "nmtui-connect" "nethack" "vim" "alsamixer" "nvim" "w3m" "psql"
          "lazygit" "lazydocker" "ncmpcpp" "newsbeuter" "nethack" "mutt" "neomutt" "tmux"
          "docker" "podman" "jqp")))

(provide 'lf-shell)
;;; lf-shell.el ends here
