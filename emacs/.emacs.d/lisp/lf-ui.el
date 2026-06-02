;;; lf-ui.el --- Fonts, themes, modeline, icons -*- lexical-binding: t; -*-
;;; Commentary:
;; Configures fonts with fallback, Modus themes with Catppuccin Mocha palette,
;; doom-modeline, diff-hl, which-key, nerd-icons, nyan-mode, dashboard,
;; rainbow-delimiters, and indent-bars.

;;; Code:

;; ──────────────────────────────────────────────
;; Fonts
;; ──────────────────────────────────────────────

(defun font-installed-p (font-name)
  "Return non-nil if FONT-NAME is available on this system."
  (find-font (font-spec :name font-name)))

(defun setup-fonts ()
  "Set up global font faces for Emacs frames."
  (cond
   ((font-installed-p "Hack Nerd Font")
    (set-face-attribute 'default nil :font "Hack Nerd Font" :height 120))
   ((font-installed-p "Iosevka Nerd Font")
    (set-face-attribute 'default nil :font "Iosevka Nerd Font" :height 120))
   ((font-installed-p "JetBrainsMono Nerd Font")
    (set-face-attribute 'default nil :font "JetBrainsMono Nerd Font" :height 120)))
  (cond
   ((font-installed-p "Inter")
    (set-face-attribute 'variable-pitch nil :font "Inter" :height 130))
   ((font-installed-p "Ubuntu")
    (set-face-attribute 'variable-pitch nil :font "Ubuntu" :height 130)))
  (cond
   ((font-installed-p "Hack Nerd Font Mono")
    (set-face-attribute 'fixed-pitch nil :font "Hack Nerd Font Mono" :height 120))
   ((font-installed-p "Iosevka Nerd Font")
    (set-face-attribute 'fixed-pitch nil :font "Iosevka Nerd Font" :height 120)))
  (when (font-installed-p "Noto Color Emoji")
    (set-fontset-font t 'emoji "Noto Color Emoji" nil 'prepend)))

(add-hook 'after-init-hook #'setup-fonts)
(add-hook 'server-after-make-frame-hook #'setup-fonts)

;; ──────────────────────────────────────────────
;; doom-themes (available but theme loaded below)
;; ──────────────────────────────────────────────

(use-package doom-themes
  :ensure t
  :defer t)

;; ──────────────────────────────────────────────
;; Modus themes — Catppuccin Mocha palette overrides
;; ──────────────────────────────────────────────

(use-package modus-themes
  :ensure nil
  :defer t
  :custom
  (modus-themes-italic-constructs t)
  (modus-themes-bold-constructs t)
  (modus-themes-mixed-fonts nil)
  (modus-themes-prompts '(bold intense))
  (modus-themes-common-palette-overrides
   `((accent-0 "#89b4fa")
     (accent-1 "#89dceb")
     (bg-active bg-main)
     (bg-added "#364144")
     (bg-added-refine "#4A5457")
     (bg-changed "#3e4b6c")
     (bg-changed-refine "#515D7B")
     (bg-completion "#45475a")
     (bg-completion-match-0 "#1e1e2e")
     (bg-completion-match-1 "#1e1e2e")
     (bg-completion-match-2 "#1e1e2e")
     (bg-completion-match-3 "#1e1e2e")
     (bg-hl-line "#2a2b3d")
     (bg-hover-secondary "#585b70")
     (bg-line-number-active unspecified)
     (bg-line-number-inactive "#1e1e2e")
     (bg-main "#1e1e2e")
     (bg-mark-delete "#443245")
     (bg-mark-select "#3e4b6c")
     (bg-mode-line-active "#181825")
     (bg-mode-line-inactive "#181825")
     (bg-prominent-err "#443245")
     (bg-prompt unspecified)
     (bg-prose-block-contents "#313244")
     (bg-prose-block-delimiter bg-prose-block-contents)
     (bg-region "#585b70")
     (bg-removed "#443245")
     (bg-removed-refine "#574658")
     (bg-tab-bar      "#1e1e2e")
     (bg-tab-current  bg-main)
     (bg-tab-other    "#1e1e2e")
     (border-mode-line-active nil)
     (border-mode-line-inactive nil)
     (builtin "#89b4fa")
     (comment "#9399b2")
     (constant  "#f38ba8")
     (cursor  "#f5e0dc")
     (date-weekday "#89b4fa")
     (date-weekend "#fab387")
     (docstring "#a6adc8")
     (err     "#f38ba8")
     (fg-active fg-main)
     (fg-completion "#cdd6f4")
     (fg-completion-match-0 "#89b4fa")
     (fg-completion-match-1 "#f38ba8")
     (fg-completion-match-2 "#a6e3a1")
     (fg-completion-match-3 "#fab387")
     (fg-heading-0 "#f38ba8")
     (fg-heading-1 "#fab387")
     (fg-heading-2 "#f9e2af")
     (fg-heading-3 "#a6e3a1")
     (fg-heading-4 "#74c7ec")
     (fg-line-number-active "#b4befe")
     (fg-line-number-inactive "#7f849c")
     (fg-link  "#89b4fa")
     (fg-main "#cdd6f4")
     (fg-mark-delete "#f38ba8")
     (fg-mark-select "#89b4fa")
     (fg-mode-line-active "#bac2de")
     (fg-mode-line-inactive "#585b70")
     (fg-prominent-err "#f38ba8")
     (fg-prompt "#cba6f7")
     (fg-prose-block-delimiter "#9399b2")
     (fg-prose-verbatim "#a6e3a1")
     (fg-region "#cdd6f4")
     (fnname    "#89b4fa")
     (fringe "#1e1e2e")
     (identifier "#cba6f7")
     (info    "#94e2d5")
     (keyword   "#cba6f7")
     (name "#89b4fa")
     (number "#fab387")
     (property "#89b4fa")
     (string "#a6e3a1")
     (type      "#f9e2af")
     (variable  "#fab387")
     (warning "#f9e2af")))
  :config
  (modus-themes-with-colors
    (custom-set-faces
     `(change-log-acknowledgment ((,c :foreground "#b4befe")))
     `(change-log-date ((,c :foreground "#a6e3a1")))
     `(change-log-name ((,c :foreground "#fab387")))
     `(diff-context ((,c :foreground "#89b4fa")))
     `(diff-file-header ((,c :foreground "#f5c2e7")))
     `(diff-header ((,c :foreground "#89b4fa")))
     `(diff-hunk-header ((,c :foreground "#fab387")))
     `(gnus-button ((,c :foreground "#8aadf4")))
     `(gnus-group-mail-3 ((,c :foreground "#8aadf4")))
     `(gnus-group-mail-3-empty ((,c :foreground "#8aadf4")))
     `(gnus-header-content ((,c :foreground "#7dc4e4")))
     `(gnus-header-from ((,c :foreground "#cba6f7")))
     `(gnus-header-name ((,c :foreground "#a6e3a1")))
     `(gnus-header-subject ((,c :foreground "#8aadf4")))
     `(log-view-message ((,c :foreground "#b4befe")))
     `(match ((,c :background "#3e5768" :foreground "#cdd6f5")))
     `(modus-themes-search-current ((,c :background "#f38ba8" :foreground "#11111b")))
     `(modus-themes-search-lazy ((,c :background "#3e5768" :foreground "#cdd6f5")))
     `(newsticker-extra-face ((,c :foreground "#9399b2" :height 0.8 :slant italic)))
     `(newsticker-feed-face ((,c :foreground "#f38ba8" :height 1.2 :weight bold)))
     `(newsticker-treeview-face ((,c :foreground "#cdd6f4")))
     `(newsticker-treeview-selection-face ((,c :background "#3e5768" :foreground "#cdd6f5")))
     `(tab-bar ((,c :background "#1e1e2e" :foreground "#bac2de")))
     `(tab-bar-tab ((,c :background "#1e1e2e" :underline t)))
     `(tab-bar-tab-group-current ((,c :background "#1e1e2e" :foreground "#bac2de" :underline t)))
     `(tab-bar-tab-group-inactive ((,c :background "#1e1e2e" :foreground "#9399b2")))))
  :init
  (load-theme 'modus-vivendi t))

;; Active modeline highlight using modus palette
(defun my-update-active-mode-line-colors ()
  "Highlight the active modeline using modus theme colors."
  (when (fboundp 'modus-themes-get-color-value)
    (set-face-attribute
     'mode-line nil
     :foreground (modus-themes-get-color-value 'fg-mode-line-active)
     :background (modus-themes-get-color-value 'bg-blue-subtle))))

(with-eval-after-load 'modus-themes
  (add-hook 'modus-themes-after-load-theme-hook #'my-update-active-mode-line-colors))

;; Turn off fringe
(set-fringe-mode 0)

;; ──────────────────────────────────────────────
;; Cursor visibility
;; ──────────────────────────────────────────────

;; blink-cursor-blinks defaults to 10 — after 10 blinks it STOPS and leaves
;; cursor invisible until you move. Setting to 0 means blink forever.
(setq blink-cursor-blinks 0
      blink-cursor-interval 0.6)
(blink-cursor-mode 1)

;; beacon: flash cursor after large jumps (scroll, window switch, etc.)
(use-package beacon
  :ensure t
  :custom
  (beacon-blink-when-window-scrolls t)
  (beacon-blink-when-window-changes t)
  (beacon-blink-when-point-moves-vertically 10)
  (beacon-color "#f5e0dc")  ; matches cursor palette
  (beacon-size 20)
  :config
  (beacon-mode 1))

;; ──────────────────────────────────────────────
;; doom-modeline
;; ──────────────────────────────────────────────

(use-package doom-modeline
  :ensure t
  :custom
  (doom-modeline-height 25)
  (doom-modeline-bar-width 3)
  :config
  (doom-modeline-mode 1))

;; ──────────────────────────────────────────────
;; diff-hl — git gutter
;; ──────────────────────────────────────────────

(use-package diff-hl
  :ensure t
  :config
  (global-diff-hl-mode 1))

;; ──────────────────────────────────────────────
;; pulsar — pulse current line on navigation
;; ──────────────────────────────────────────────

(use-package pulsar
  :ensure t
  :custom
  (pulsar-pulse t)
  (pulsar-delay 0.055)
  (pulsar-iterations 10)
  (pulsar-face 'pulsar-magenta)
  :config
  (pulsar-global-mode 1)
  (dolist (fn '(avy-goto-char-timer
                consult-line
                consult-imenu
                consult-goto-line
                flymake-goto-next-error
                flymake-goto-prev-error))
    (add-to-list 'pulsar-pulse-functions fn)))

;; ──────────────────────────────────────────────
;; which-key
;; ──────────────────────────────────────────────

(use-package which-key
  :ensure t
  :config
  (which-key-mode 1))

;; ──────────────────────────────────────────────
;; diminish
;; ──────────────────────────────────────────────

(use-package diminish
  :ensure t)

;; ──────────────────────────────────────────────
;; nerd-icons
;; ──────────────────────────────────────────────

(use-package nerd-icons
  :ensure t)

(use-package nerd-icons-completion
  :ensure t
  :after (marginalia nerd-icons)
  :hook (marginalia-mode . nerd-icons-completion-marginalia-setup)
  :init (nerd-icons-completion-mode))

;; nerd-icons-dired disabled: dirvish already renders nerd-icons via
;; dirvish-attributes, enabling both causes duplicate icons in dired buffers.
;; (use-package nerd-icons-dired
;;   :ensure t
;;   :hook (dired-mode . nerd-icons-dired-mode))

;; ──────────────────────────────────────────────
;; nyan-mode
;; ──────────────────────────────────────────────

(use-package nyan-mode
  :ensure t
  :custom
  (nyan-bar-length 20)
  (nyan-wavy-trail t)
  (nyan-animate-nyancat t)
  (nyan-minimum-window-width 64)
  :init
  (nyan-mode 1))

;; ──────────────────────────────────────────────
;; dashboard
;; ──────────────────────────────────────────────

(use-package dashboard
  :ensure t
  :after nerd-icons
  :hook (dashboard-mode . (lambda () (display-line-numbers-mode 0)))
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-center-content t
        dashboard-startup-banner (expand-file-name "~/.config/emacs/emacs_banner.png")
        dashboard-icon-type 'nerd-icons
        dashboard-display-icons-p t
        dashboard-items '((recents   . 5)
                          (projects  . 5)
                          (bookmarks . 5)
                          (agenda    . 5))
        dashboard-projects-backend 'project-el
        dashboard-footer-messages
        '("The one true editor, Emacs!"
          "Free as free speech, free as free Beer"
          "Happy coding!"
          "I use Emacs, which might be thought of as a thermonuclear word processor. --Neal Stephenson"
          "Welcome to the church of Emacs"
          "In the beginning was the lambda, and the lambda was with Emacs, and Emacs was the lambda."
          "While any text editor can save your files, only Emacs can save your soul")))

;; ──────────────────────────────────────────────
;; rainbow-delimiters (hook added in lf-prog.el)
;; ──────────────────────────────────────────────

(use-package rainbow-delimiters
  :ensure t
  :defer t)

;; ──────────────────────────────────────────────
;; indent-bars
;; ──────────────────────────────────────────────

(use-package indent-bars
  :ensure t
  :custom
  (indent-bars-treesit-support t)
  (indent-bars-no-descend-string t)
  (indent-bars-treesit-ignore-blank-lines-types '("module"))
  (indent-bars-width-frac 0.1)
  (indent-bars-pad-frac 0.1)
  (indent-bars-zigzag nil)
  (indent-bars-color '(highlight :face-bg t :blend 0.2))
  (indent-bars-pattern ".")
  (indent-bars-color-by-depth '(:regexp "outline-\\([0-9]+\\)" :blend 1))
  (indent-bars-highlight-current-depth '(:blend 0.5))
  :hook ((prog-mode yaml-mode ruby-mode ruby-ts-mode) . indent-bars-mode))

(provide 'lf-ui)
;;; lf-ui.el ends here
