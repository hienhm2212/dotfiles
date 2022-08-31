;; NOTE: init.el is now generated from Emacs.org.  Please edit that file
;;       in Emacs and init.el will be generated automatically!

;; You will most likely need to adjust this font size for your system!
(defvar efs/default-font-size 110)
(defvar efs/default-variable-font-size 110)

;; Make frame transparency overridable
(defvar efs/frame-transparency '(100 . 90))
;; Define constans
(defconst *sys/win32*
  (eq system-type 'windows-nt)
  "Are we running on a WinTel system?")

(defconst *sys/linux*
  (eq system-type 'gnu/linux)
  "Are we running on a GNU/Linux system?")

(defconst *sys/mac*
  (eq system-type 'darwin)
  "Are we running on a Mac system?")

(defconst python-p
  (or (executable-find "python3")
(and (executable-find "python")
	   (> (length (shell-command-to-string "python --version | grep 'Python 3'")) 0)))
  "Do we have python3?")

(defconst pip-p
  (or (executable-find "pip3")
(and (executable-find "pip")
	   (> (length (shell-command-to-string "pip --version | grep 'python 3'")) 0)))
  "Do we have pip3?")

(defconst clangd-p
  (or (executable-find "clangd")  ;; usually
(executable-find "/usr/local/opt/llvm/bin/clangd"))  ;; macOS
  "Do we have clangd?")

(defconst eaf-env-p
  (and (display-graphic-p) python-p pip-p)
  "Do we have EAF environment setup?")

;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

(defun efs/display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                     (time-subtract after-init-time before-init-time)))
           gcs-done))

(add-hook 'emacs-startup-hook #'efs/display-startup-time)

(setq user-full-name "Hien Huynh-Minh")
(setq user-mail-address "blackcat22121996@gmail.com")

;; Unbind unneeded keys
(global-set-key (kbd "C-z") nil)

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

  ;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package auto-package-update
  :custom
  (auto-package-update-interval 7)
  (auto-package-update-prompt-before-update t)
  (auto-package-update-hide-results t)
  :config
  (auto-package-update-maybe)
  (auto-package-update-at-time "09:00"))

(use-package diminish)

;; NOTE: If you want to move everything out of the ~/.emacs.d folder
;; reliably, set `user-emacs-directory` before loading no-littering!
;(setq user-emacs-directory "~/.cache/emacs")

(use-package no-littering)

;; no-littering doesn't set this by default so we must place
;; auto save files in the same path as it uses for sessions
(setq auto-save-file-name-transforms
      `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

(setq inhibit-startup-message t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room

(menu-bar-mode -1)            ; Disable the menu bar

;; Set up the visible bell
(setq visible-bell t)

(column-number-mode)
(global-display-line-numbers-mode t)

;; Set frame transparency
(set-frame-parameter (selected-frame) 'alpha efs/frame-transparency)
(add-to-list 'default-frame-alist `(alpha . ,efs/frame-transparency))
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                treemacs-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(set-face-attribute 'default nil :font "Fira Code Retina" :height efs/default-font-size)

;; Set the fixed pitch face
(set-face-attribute 'fixed-pitch nil :font "Fira Code Retina" :height efs/default-font-size)

;; Set the variable pitch face
(set-face-attribute 'variable-pitch nil :font "Cantarell" :height efs/default-variable-font-size :weight 'regular)

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(use-package general
  :after evil
  :config
  (general-create-definer efs/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (efs/leader-keys
    "t"  '(:ignore t :which-key "toggles")
    "tt" '(counsel-load-theme :which-key "choose theme")
    "fde" '(lambda () (interactive) (find-file (expand-file-name "~/.emacs.d/Emacs.org")))))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(unless *sys/win32*
  (set-selection-coding-system 'utf-8)
  (prefer-coding-system 'utf-8)
  (set-language-environment "UTF-8")
  (set-default-coding-systems 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8)
  (setq locale-coding-system 'utf-8))
;; Treat clipboard input as UTF-8 string first; compound text next, etc.
(when (display-graphic-p)
  (setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING)))

;; Remove useless whitespace before saving a file
(defun delete-trailing-whitespace-except-current-line ()
  "An alternative to `delete-trailing-whitespace'.

The original function deletes trailing whitespace of the current line."
  (interactive)
  (let ((begin (line-beginning-position))
        (end (line-end-position)))
    (save-excursion
      (when (< (point-min) (1- begin))
        (save-restriction
          (narrow-to-region (point-min) (1- begin))
          (delete-trailing-whitespace)
          (widen)))
      (when (> (point-max) (+ end 2))
        (save-restriction
          (narrow-to-region (+ end 2) (point-max))
          (delete-trailing-whitespace)
          (widen))))))

(defun smart-delete-trailing-whitespace ()
  "Invoke `delete-trailing-whitespace-except-current-line' on selected major modes only."
  (unless (member major-mode '(diff-mode))
    (delete-trailing-whitespace-except-current-line)))

(add-hook 'before-save-hook #'smart-delete-trailing-whitespace)

;; Replace selection on insert
(delete-selection-mode 1)

;; Map Alt key to Meta
;; (setq x-alt-keysym 'meta)

(use-package command-log-mode
  :commands command-log-mode)

(use-package doom-themes
  :custom-face
  (cursor ((t (:background "BlanchedAlmond"))))
  :config
  ;; flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config)
  (load-theme 'doom-one t)
  (defun switch-theme ()
    "An interactive funtion to switch themes."
    (interactive)
    (disable-theme (intern (car (mapcar #'symbol-name custom-enabled-themes))))
    (call-interactively #'load-theme)))

(use-package all-the-icons :if (display-graphic-p))

(use-package doom-modeline
  :custom
  ;; Don't compact font caches during GC. Windows Laggy Issue
  (inhibit-compacting-font-caches t)
  (doom-modeline-minor-modes t)
  (doom-modeline-icon t)
  (doom-modeline-major-mode-color-icon t)
  (doom-modeline-height 15)
  :config
  (doom-modeline-mode))

;; Vertical Scroll
(setq scroll-step 1)
(setq scroll-margin 1)
(setq scroll-conservatively 101)
(setq scroll-up-aggressively 0.01)
(setq scroll-down-aggressively 0.01)
(setq auto-window-vscroll nil)
(setq fast-but-imprecise-scrolling nil)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))
(setq mouse-wheel-progressive-speed nil)
;; Horizontal Scroll
(setq hscroll-step 1)
(setq hscroll-margin 1)

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 1))

(use-package dashboard
:demand
:diminish (dashboard-mode page-break-lines-mode)
:bind
(("C-z d" . open-dashboard)
 :map dashboard-mode-map
 (("n" . dashboard-next-line)
  ("p" . dashboard-previous-line)
  ("N" . dashboard-next-section)
  ("F" . dashboard-previous-section)))
:custom
(dashboard-banner-logo-title "Close the world. Open the nExt.")
(dashboard-startup-banner (expand-file-name "images/KEC_Dark_BK_Small.png" user-emacs-directory))
(dashboard-items '((recents  . 7)
                   (bookmarks . 7)
                   (agenda . 5)))
(initial-buffer-choice (lambda () (get-buffer dashboard-buffer-name)))
(dashboard-set-heading-icons t)
(dashboard-set-navigator t)
(dashboard-navigator-buttons
 (if (featurep 'all-the-icons)
     `(((,(all-the-icons-octicon "mark-github" :height 1.1 :v-adjust -0.05)
         "EMACS" "Browse EMACS Homepage"
         (lambda (&rest _) (browse-url "https://github.com/MatthewZMD/.emacs.d")))
        (,(all-the-icons-fileicon "elisp" :height 1.0 :v-adjust -0.1)
         "Configuration" "" (lambda (&rest _) (edit-configs)))
        (,(all-the-icons-faicon "cogs" :height 1.0 :v-adjust -0.1)
         "Update" "" (lambda (&rest _) (auto-package-update-now)))))
   `((("" "EMACS" "Browse EMACS Homepage"
       (lambda (&rest _) (browse-url "https://github.com/MatthewZMD/.emacs.d")))
      ("" "Configuration" "" (lambda (&rest _) (edit-configs)))
      ("" "Update" "" (lambda (&rest _) (auto-package-update-now)))))))
:custom-face
(dashboard-banner-logo-title ((t (:family "Love LetterTW" :height 123))))
:config
(dashboard-modify-heading-icons '((recents . "file-text")
                                  (bookmarks . "book")))
(dashboard-setup-startup-hook)
;; Open Dashboard function
(defun open-dashboard ()
  "Open the *dashboard* buffer and jump to the first widget."
  (interactive)
  (dashboard-insert-startupify-lists)
  (switch-to-buffer dashboard-buffer-name)
  (goto-char (point-min))
  (delete-other-windows)))

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package ivy-rich
  :after ivy
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :bind (("C-M-j" . 'counsel-switch-buffer)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :custom
  (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
  :config
  (counsel-mode 1))

(use-package ivy-prescient
  :after counsel
  :custom
  (ivy-prescient-enable-filtering nil)
  :config
  ;; Uncomment the following line to have sorting remembered across sessions!
  ;(prescient-persist-mode 1)
  (ivy-prescient-mode 1))

(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package hydra
  :defer t)

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(efs/leader-keys
  "ts" '(hydra-text-scale/body :which-key "scale text"))

(use-package highlight-indent-guides
:if (display-graphic-p)
:diminish
;; Enable manually if needed, it a severe bug which potentially core-dumps Emacs
;; https://github.com/DarthFennec/highlight-indent-guides/issues/76
:commands (highlight-indent-guides-mode)
:mode ("\\.yml\\'" . highlight-indent-guides-mode)
:custom
(highlight-indent-guides-method 'character)
(highlight-indent-guides-responsive 'top)
(highlight-indent-guides-delay 0)
(highlight-indent-guides-auto-character-face-perc 7))

(setq-default indent-tabs-mode nil)
(setq-default indent-line-function 'insert-tab)
(setq-default tab-width 2)
(setq-default c-basic-offset 4)
(setq-default js-switch-indent-offset 2)
(c-set-offset 'comment-intro 0)
(c-set-offset 'innamespace 0)
(c-set-offset 'case-label '+)
(c-set-offset 'access-label 0)
(c-set-offset (quote cpp-macro) 0 nil)
(defun smart-electric-indent-mode ()
  "Disable 'electric-indent-mode in certain buffers and enable otherwise."
  (cond ((and (eq electric-indent-mode t)
              (member major-mode '(erc-mode text-mode)))
         (electric-indent-mode 0))
        ((eq electric-indent-mode nil) (electric-indent-mode 1))))
(add-hook 'post-command-hook #'smart-electric-indent-mode)

(use-package format-all
:bind ("C-c C-f" . format-all-buffer))

(global-hl-line-mode 1)

(global-prettify-symbols-mode 1)
(defun add-pretty-lambda ()
  "Make some word or string show as pretty Unicode symbols.  See https://unicodelookup.com for more."
  (setq prettify-symbols-alist
        '(("lambda" . 955)
          ("delta" . 120517)
          ("epsilon" . 120518)
          ("->" . 8594)
          ("<=" . 8804)
          (">=" . 8805))))
(add-hook 'prog-mode-hook 'add-pretty-lambda)
(add-hook 'org-mode-hook 'add-pretty-lambda)

(fset 'yes-or-no-p 'y-or-n-p)
(setq use-dialog-box nil)

(use-package page-break-lines
:diminish
:init (global-page-break-lines-mode))

(use-package color-rg
:load-path (lambda () (expand-file-name "site-elisp/color-rg" user-emacs-directory))
:if (executable-find "rg")
:bind ("C-M-s" . color-rg-search-input))

(use-package avy
:defer t
:bind
(("C-z c" . avy-goto-char-timer)
 ("C-z l" . avy-goto-line))
:custom
(avy-timeout-seconds 0.3)
(avy-style 'pre)
:custom-face
(avy-lead-face ((t (:background "#51afef" :foreground "#870000" :weight bold)))));

(defun efs/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil    :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-table nil    :inherit 'fixed-pitch)
  (set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil     :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil    :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil  :inherit 'fixed-pitch)
  (set-face-attribute 'line-number nil :inherit 'fixed-pitch)
  (set-face-attribute 'line-number-current-line nil :inherit 'fixed-pitch))

(defun efs/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(use-package org
  :pin org
  :commands (org-capture org-agenda)
  :hook (org-mode . efs/org-mode-setup)
  :config
  (setq org-ellipsis " ▾")

  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)

  (setq org-agenda-files
        '("~/Projects/OrgFiles/Tasks.org"
          "~/Projects/OrgFiles/Habits.org"
          "~/Projects/OrgFiles/Birthdays.org"))

  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60)

  (setq org-todo-keywords
    '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
      (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))

  (setq org-refile-targets
    '(("Archive.org" :maxlevel . 1)
      ("Tasks.org" :maxlevel . 1)))

  ;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers)

  (setq org-tag-alist
    '((:startgroup)
       ; Put mutually exclusive tags here
       (:endgroup)
       ("@errand" . ?E)
       ("@home" . ?H)
       ("@work" . ?W)
       ("agenda" . ?a)
       ("planning" . ?p)
       ("publish" . ?P)
       ("batch" . ?b)
       ("note" . ?n)
       ("idea" . ?i)))

  ;; Configure custom agenda views
  (setq org-agenda-custom-commands
   '(("d" "Dashboard"
     ((agenda "" ((org-deadline-warning-days 7)))
      (todo "NEXT"
        ((org-agenda-overriding-header "Next Tasks")))
      (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))

    ("n" "Next Tasks"
     ((todo "NEXT"
        ((org-agenda-overriding-header "Next Tasks")))))

    ("W" "Work Tasks" tags-todo "+work-email")

    ;; Low-effort next actions
    ("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
     ((org-agenda-overriding-header "Low Effort Tasks")
      (org-agenda-max-todos 20)
      (org-agenda-files org-agenda-files)))

    ("w" "Workflow Status"
     ((todo "WAIT"
            ((org-agenda-overriding-header "Waiting on External")
             (org-agenda-files org-agenda-files)))
      (todo "REVIEW"
            ((org-agenda-overriding-header "In Review")
             (org-agenda-files org-agenda-files)))
      (todo "PLAN"
            ((org-agenda-overriding-header "In Planning")
             (org-agenda-todo-list-sublevels nil)
             (org-agenda-files org-agenda-files)))
      (todo "BACKLOG"
            ((org-agenda-overriding-header "Project Backlog")
             (org-agenda-todo-list-sublevels nil)
             (org-agenda-files org-agenda-files)))
      (todo "READY"
            ((org-agenda-overriding-header "Ready for Work")
             (org-agenda-files org-agenda-files)))
      (todo "ACTIVE"
            ((org-agenda-overriding-header "Active Projects")
             (org-agenda-files org-agenda-files)))
      (todo "COMPLETED"
            ((org-agenda-overriding-header "Completed Projects")
             (org-agenda-files org-agenda-files)))
      (todo "CANC"
            ((org-agenda-overriding-header "Cancelled Projects")
             (org-agenda-files org-agenda-files)))))))

  (setq org-capture-templates
    `(("t" "Tasks / Projects")
      ("tt" "Task" entry (file+olp "~/Projects/OrgFiles/Tasks.org" "Inbox")
           "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)

      ("j" "Journal Entries")
      ("jj" "Journal" entry
           (file+olp+datetree "~/Projects/OrgFiles/Journal.org")
           "\n* %<%I:%M %p> - Journal :journal:\n\n%?\n\n"
           ;; ,(dw/read-file-as-string "~/Notes/Templates/Daily.org")
           :clock-in :clock-resume
           :empty-lines 1)
      ("jm" "Meeting" entry
           (file+olp+datetree "~/Projects/OrgFiles/Journal.org")
           "* %<%I:%M %p> - %a :meetings:\n\n%?\n\n"
           :clock-in :clock-resume
           :empty-lines 1)

      ("w" "Workflows")
      ("we" "Checking Email" entry (file+olp+datetree "~/Projects/OrgFiles/Journal.org")
           "* Checking Email :email:\n\n%?" :clock-in :clock-resume :empty-lines 1)

      ("m" "Metrics Capture")
      ("mw" "Weight" table-line (file+headline "~/Projects/OrgFiles/Metrics.org" "Weight")
       "| %U | %^{Weight} | %^{Notes} |" :kill-buffer t)))

  (define-key global-map (kbd "C-c j")
    (lambda () (interactive) (org-capture nil "jj")))

  (efs/org-font-setup))

(use-package org-bullets
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(defun efs/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . efs/org-mode-visual-fill))

(with-eval-after-load 'org
  (org-babel-do-load-languages
      'org-babel-load-languages
      '((emacs-lisp . t)
      (python . t)))

  (push '("conf-unix" . conf-unix) org-src-lang-modes))

(with-eval-after-load 'org
  ;; This is needed as of Org 9.2
  (require 'org-tempo)

  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python")))

;; Automatically tangle our Emacs.org config file when we save it
(defun efs/org-babel-tangle-config ()
  (when (string-equal (file-name-directory (buffer-file-name))
                      (expand-file-name user-emacs-directory))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'efs/org-babel-tangle-config)))

(use-package toc-org
:hook (org-mode . toc-org-mode))

(use-package htmlize :defer t)

(use-package plantuml-mode
:defer t
:custom
(org-plantuml-jar-path (expand-file-name "~/tools/plantuml/plantuml.jar")))

(use-package pdf-tools-install
:ensure pdf-tools
:if (and (display-graphic-p) (not *sys/win32*) (not eaf-env-p))
:mode "\\.pdf\\'"
:commands (pdf-loader-install)
:custom
(TeX-view-program-selection '((output-pdf "pdf-tools")))
(TeX-view-program-list '(("pdf-tools" "TeX-pdf-tools-sync-view")))
:hook
(pdf-view-mode . (lambda () (display-line-numbers-mode -1)))
:config
(pdf-loader-install))

;; (use-package eaf
;; :load-path (lambda () (expand-file-name "site-lisp/emacs-application-framework" user-emacs-directory))
;; :if eaf-env-p
;; :custom
;; (browse-url-browser-function #'eaf-open-browser) ;; Make EAF Browser my default browser
;; (eaf-start-python-process-when-require t)
;; (eaf-browser-dark-mode nil)
;; (eaf-browser-enable-adblocker t)
;; (eaf-webengine-continue-where-left-off t)
;; (eaf-webengine-default-zoom 1.25)
;; (eaf-webengine-scroll-step 200)
;; (eaf-file-manager-show-preview nil)
;; (eaf-pdf-dark-mode "ignore")
;; :demand
;; :bind
;; (("C-x j" . eaf-open-in-file-manager)
;;  ("M-z r" . eaf-open-rss-reader)
;;  ("M-m r" . eaf-open-rss-reader))
;; :config
;; ;; Require all EAF apps unconditionally, change to apps you're interested in.
;; (require 'eaf-file-manager nil t)
;; (require 'eaf-music-player nil t)
;; (require 'eaf-image-viewer nil t)
;; (require 'eaf-camera nil t)
;; (require 'eaf-demo nil t)
;; (require 'eaf-airshare nil t)
;; (require 'eaf-terminal nil t)
;; (require 'eaf-markdown-previewer nil t)
;; (require 'eaf-video-player nil t)
;; (require 'eaf-vue-demo nil t)
;; (require 'eaf-file-sender nil t)
;; (require 'eaf-pdf-viewer nil t)
;; (require 'eaf-mindmap nil t)
;; (require 'eaf-netease-cloud-music nil t)
;; (require 'eaf-jupyter nil t)
;; (require 'eaf-org-previewer nil t)
;; (require 'eaf-system-monitor nil t)
;; (require 'eaf-rss-reader nil t)
;; (require 'eaf-file-browser nil t)
;; (require 'eaf-browser nil t)
;; (require 'eaf-org)
;; (require 'eaf-mail)
;; (require 'eaf-git)
;; (when (display-graphic-p)
;;   (require 'eaf-all-the-icons))
;; (defalias 'browse-web #'eaf-open-browser)
;; (eaf-bind-key nil "M-q" eaf-browser-keybinding)
;; (eaf-bind-key open_link "C-M-s" eaf-browser-keybinding)
;; (eaf-bind-key open_devtools "M-i" eaf-browser-keybinding)
;; (eaf-bind-key insert_or_recover_prev_close_page "X" eaf-browser-keybinding)
;; (eaf-bind-key scroll_up "RET" eaf-pdf-viewer-keybinding)
;; (eaf-bind-key delete_cookies "C-M-q" eaf-browser-keybinding)
;; (eaf-bind-key delete_all_cookies "C-M-Q" eaf-browser-keybinding)
;; (eaf-bind-key clear_history "C-M-p" eaf-browser-keybinding)
;; (eaf-bind-key scroll_down_page "DEL" eaf-pdf-viewer-keybinding)
;; (eaf-bind-key scroll_down_page "u" eaf-pdf-viewer-keybinding)
;; (eaf-bind-key scroll_up_page "d" eaf-pdf-viewer-keybinding)
;; (eaf-bind-key scroll_to_end "M->" eaf-pdf-viewer-keybinding)
;; (eaf-bind-key scroll_to_begin "M-<" eaf-pdf-viewer-keybinding)
;; (eaf-bind-key quit-window "q" eaf-pdf-viewer-keybinding)
;; (eaf-bind-key zoom_in "C-=" eaf-pdf-viewer-keybinding)
;; (eaf-bind-key zoom_out "C--" eaf-pdf-viewer-keybinding)
;; (eaf-bind-key take_photo "p" eaf-camera-keybinding)
;; (eaf-bind-key eaf-send-key-sequence "M-]" eaf-terminal-keybinding)
;; (eaf-bind-key eaf-send-key-sequence "M-]" eaf-terminal-keybinding)
;; (eaf-bind-key js_select_next_file "n" eaf-file-manager-keybinding)
;; (eaf-bind-key js_select_prev_file "p" eaf-file-manager-keybinding)
;; (eaf-bind-key new_file "F" eaf-file-manager-keybinding)
;; (eaf-bind-key new_directory "D" eaf-file-manager-keybinding)
;; (eaf-bind-key toggle_preview "P" eaf-file-manager-keybinding))

;; (use-package popweb
;; :if eaf-env-p
;; :load-path (lambda () (expand-file-name "site-elisp/popweb" user-emacs-directory))
;; :init
;; (add-to-list 'load-path (expand-file-name "site-elisp/popweb/extension/latex" user-emacs-directory))
;; (add-to-list 'load-path (expand-file-name "site-elisp/popweb/extension/dict" user-emacs-directory))
;; (require 'popweb-latex)
;; (require 'popweb-dict-youdao)
;; :custom
;; (popweb-popup-pos "point-bottom")
;; :hook ((org-mode . popweb-latex-mode)
;;        (tex-mode . popweb-latex-mode)
;;        (ein:markdown-mode . popweb-latex-mode))
;; )

(use-package eww
:ensure nil
:commands (eww)
:hook (eww-mode . (lambda ()
                    "Rename EWW's buffer so sites open in new page."
                    (rename-buffer "eww" t)))
:config
;; I am using EAF-Browser instead of EWW
(unless eaf-env-p
  (setq browse-url-browser-function 'eww-browse-url))) ; Hit & to browse url with system browser

(defun efs/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . efs/lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package lsp-treemacs
  :after lsp)

(use-package lsp-ivy
  :after lsp)

(use-package dap-mode
  ;; Uncomment the config below if you want all UI panes to be hidden by default!
  ;; :custom
  ;; (lsp-enable-dap-auto-configure nil)
  ;; :config
  ;; (dap-ui-mode 1)
  :commands dap-debug
  :config
  ;; Set up Node debugging
  (require 'dap-node)
  (dap-node-setup) ;; Automatically installs Node debug adapter if needed

  ;; Bind `C-c l d` to `dap-hydra` for easy access
  (general-define-key
    :keymaps 'lsp-mode-map
    :prefix lsp-keymap-prefix
    "d" '(dap-hydra t :wk "debugger")))

(use-package typescript-mode
  :mode "\\.ts\\'"
  :hook (typescript-mode . lsp-deferred)
  :config
  (setq typescript-indent-level 2))

(use-package python-mode
  :ensure t
  :hook (python-mode . lsp-deferred)
  :custom
  ;; NOTE: Set these if Python 3 is called "python3" on your system!
  ;; (python-shell-interpreter "python3")
  ;; (dap-python-executable "python3")
  (dap-python-debugger 'debugpy)
  :config
  (require 'dap-python))

(use-package pyvenv
  :after python-mode
  :config
  (pyvenv-mode 1))

(use-package go-mode
:mode "\\.go\\'"
:hook (before-save . gofmt-before-save)
:custom (gofmt-command "goimports"))

(use-package ruby-mode
  :ensure t
  :mode "\\.rb\\'"
  :mode "Rakefile\\'"
  :mode "Gemfile\\'"
  :mode "Berksfile\\'"
  :mode "Vagrantfile\\'"
  :interpreter "ruby"

  :init
  (setq ruby-indent-level 2
        ruby-indent-tabs-mode nil)
  (add-hook 'ruby-mode 'superword-mode)

  :bind
  (([(meta down)] . ruby-forward-sexp)
   ([(meta up)]   . ruby-backward-sexp)
   (("C-c C-e"    . ruby-send-region))))  ;; Rebind since Rubocop uses C-c C-r

(use-package rvm
:ensure t
:config
(rvm-use-default))

(use-package yari
:ensure t
:init
(add-hook 'ruby-mode-hook
          (lambda ()
            (local-set-key [f1] 'yari))))

(use-package inf-ruby
:ensure t
:init
(add-hook 'ruby-mode-hook 'inf-ruby-minor-mode))

(use-package smartparens
:ensure t
:diminish (smartparens-mode .  "()")
:init
  ;; (use-package smartparens-ruby)
  (add-hook 'ruby-mode-hook 'smartparens-strict-mode))

(use-package rubocop
:ensure t
:init
(add-hook 'ruby-mode-hook 'rubocop-mode)
:diminish rubocop-mode)

(use-package robe
:ensure t
:bind ("C-M-." . robe-jump)

:init
(add-hook 'ruby-mode-hook 'robe-mode)

:config
(defadvice inf-ruby-console-auto
  (before activate-rvm-for-robe activate)
  (rvm-activate-corresponding-ruby)))

(use-package ruby-tools
:ensure t
:init
(add-hook 'ruby-mode-hook 'ruby-tools-mode)
:diminish ruby-tools-mode)

(use-package rust-mode
:mode "\\.rs\\'"
:custom
(rust-format-on-save t)
:bind (:map rust-mode-map ("C-c C-c" . rust-run))
:config
(use-package flycheck-rust
  :after flycheck
  :config
  (with-eval-after-load 'rust-mode
    (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))))

(use-package yaml-mode
:defer t
:bind (("C-c p" . yaml-get-path-at-point))
:mode "\\.yml\\'"
:config
(use-package yaml-pro
  :hook (yaml-mode . yaml-pro-mode)
  :bind (("C-c M-p" . yaml-pro-move-subtree-up)
         ("C-c M-n" . yaml-pro-move-subtree-down)))
;; Based on https://github.com/chopmo/dotfiles/blob/master/.emacs.d/customizations/yaml.el
(defun yaml-indentation-level (s)
  (if (string-match "^ " s)
      (+ 1 (yaml-indentation-level (substring s 1)))
    0))
(defun yaml-clean-string (s)
  (let* ((s (replace-regexp-in-string "^[ -:]*" "" s))
         (s (replace-regexp-in-string ":$" "" s)))
    s))
(defun yaml-path-at-point ()
  (save-excursion
    (let* ((line (buffer-substring-no-properties (point-at-bol) (point-at-eol)))
           (level (yaml-indentation-level line))
           result)
      (while (> (point) (point-min))
        (beginning-of-line 0)
        (setq line (buffer-substring-no-properties (point-at-bol) (point-at-eol)))
        (let ((new-level (yaml-indentation-level line)))
          (when (and (string-match "[^[:blank:]]" line)
                     (< new-level level))
            (setq level new-level)
            (setq result (push (yaml-clean-string line) result)))))
      (mapconcat 'identity result " => "))))
(defun yaml-get-path-at-point ()
  "Display the yaml path at point for 5 seconds"
  (interactive)
  (let ((ov (display-line-overlay+ (window-start) (yaml-path-at-point))))
    (run-with-timer 1 nil (lambda () (when (overlayp ov)
                                       (delete-overlay ov)))))))

(use-package flycheck
:defer t
:diminish
:hook (after-init . global-flycheck-mode)
:commands (flycheck-add-mode)
:custom
(flycheck-global-modes
 '(not outline-mode diff-mode shell-mode eshell-mode term-mode))
(flycheck-emacs-lisp-load-path 'inherit)
(flycheck-indication-mode (if (display-graphic-p) 'right-fringe 'right-margin))
:init
(if (display-graphic-p)
    (use-package flycheck-posframe
      :custom-face
      (flycheck-posframe-face ((t (:foreground ,(face-foreground 'success)))))
      (flycheck-posframe-info-face ((t (:foreground ,(face-foreground 'success)))))
      :hook (flycheck-mode . flycheck-posframe-mode)
      :custom
      (flycheck-posframe-position 'window-bottom-left-corner)
      (flycheck-posframe-border-width 3)
      (flycheck-posframe-inhibit-functions
       '((lambda (&rest _) (bound-and-true-p company-backend)))))
  (use-package flycheck-pos-tip
    :defines flycheck-pos-tip-timeout
    :hook (flycheck-mode . flycheck-pos-tip-mode)
    :custom (flycheck-pos-tip-timeout 30)))
:config
(use-package flycheck-popup-tip
  :hook (flycheck-mode . flycheck-popup-tip-mode))
(when (fboundp 'define-fringe-bitmap)
  (define-fringe-bitmap 'flycheck-fringe-bitmap-double-arrow
    [16 48 112 240 112 48 16] nil nil 'center))
(when (executable-find "vale")
  (use-package flycheck-vale
    :config
    (flycheck-vale-setup)
    (flycheck-add-mode 'vale 'latex-mode))))

(use-package flyspell
:ensure nil
:diminish
:if (executable-find "aspell")
:hook (((text-mode outline-mode latex-mode org-mode markdown-mode) . flyspell-mode))
:custom
(flyspell-issue-message-flag nil)
(ispell-program-name "aspell")
(ispell-extra-args
 '("--sug-mode=ultra" "--lang=en_US" "--camel-case"))
:config
(use-package flyspell-correct-ivy
  :after ivy
  :bind
  (:map flyspell-mode-map
        ([remap flyspell-correct-word-before-point] . flyspell-correct-wrapper)
        ("C-." . flyspell-correct-wrapper))
  :custom (flyspell-correct-interface #'flyspell-correct-ivy)))

(use-package docker :defer t)

(use-package dockerfile-mode :defer t)

(use-package groovy-mode :defer t)

(use-package web-mode
:custom-face
(css-selector ((t (:inherit default :foreground "#66CCFF"))))
(font-lock-comment-face ((t (:foreground "#828282"))))
:mode
("\\.phtml\\'" "\\.tpl\\.php\\'" "\\.[agj]sp\\'" "\\.as[cp]x\\'"
 "\\.erb\\'" "\\.mustache\\'" "\\.djhtml\\'" "\\.[t]?html?\\'"))

(use-package js2-mode
:mode "\\.js\\'"
:interpreter "node")

(use-package typescript-mode
:mode "\\.ts\\'"
:commands (typescript-mode))

(use-package emmet-mode
:hook ((web-mode . emmet-mode)
       (css-mode . emmet-mode)))

(use-package instant-rename-tag
:load-path (lambda () (expand-file-name "site-elisp/instant-rename-tag" user-emacs-directory))
:bind ("C-z <" . instant-rename-tag))

(use-package json-mode
:mode "\\.json\\'")

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/Projects/Code")
    (setq projectile-project-search-path '("~/Projects/Code")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :after projectile
  :config (counsel-projectile-mode))

(use-package magit
  :commands magit-status
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; NOTE: Make sure to configure a GitHub token before using this package!
;; - https://magit.vc/manual/forge/Token-Creation.html#Token-Creation
;; - https://magit.vc/manual/ghub/Getting-Started.html#Getting-Started
(use-package forge
  :after magit)

(use-package evil-nerd-commenter
  :bind ("M-/" . evilnc-comment-or-uncomment-lines))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package multiple-cursors
  :bind (("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)
         ))

(use-package term
  :commands term
  :config
  (setq explicit-shell-file-name "bash") ;; Change this to zsh, etc
  ;;(setq explicit-zsh-args '())         ;; Use 'explicit-<shell>-args for shell-specific args

  ;; Match the default Bash shell prompt.  Update this if you have a custom prompt
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *"))

(use-package eterm-256color
  :hook (term-mode . eterm-256color-mode))

(use-package vterm
  :commands vterm
  :config
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *")  ;; Set this to match your custom shell prompt
  ;;(setq vterm-shell "zsh")                       ;; Set this to customize the shell to launch
  (setq vterm-max-scrollback 10000))

(when (eq system-type 'windows-nt)
  (setq explicit-shell-file-name "powershell.exe")
  (setq explicit-powershell.exe-args '()))

(defun efs/configure-eshell ()
  ;; Save command history when commands are entered
  (add-hook 'eshell-pre-command-hook 'eshell-save-some-history)

  ;; Truncate buffer for performance
  (add-to-list 'eshell-output-filter-functions 'eshell-truncate-buffer)

  ;; Bind some useful keys for evil-mode
  (evil-define-key '(normal insert visual) eshell-mode-map (kbd "C-r") 'counsel-esh-history)
  (evil-define-key '(normal insert visual) eshell-mode-map (kbd "<home>") 'eshell-bol)
  (evil-normalize-keymaps)

  (setq eshell-history-size         10000
        eshell-buffer-maximum-lines 10000
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input t))

(use-package eshell-git-prompt
  :after eshell)

(use-package eshell
  :hook (eshell-first-time-mode . efs/configure-eshell)
  :config

  (with-eval-after-load 'esh-opt
    (setq eshell-destroy-buffer-when-process-dies t)
    (setq eshell-visual-commands '("htop" "zsh" "vim")))

  (eshell-git-prompt-use-theme 'powerline))

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :custom ((dired-listing-switches "-agho --group-directories-first"))
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-single-up-directory
    "l" 'dired-single-buffer))

(use-package dired-single
  :commands (dired dired-jump))

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-open
  :commands (dired dired-jump)
  :config
  ;; Doesn't work as expected!
  ;;(add-to-list 'dired-open-functions #'dired-open-xdg t)
  (setq dired-open-extensions '(("png" . "feh")
                                ("mkv" . "mpv"))))

(use-package dired-hide-dotfiles
  :hook (dired-mode . dired-hide-dotfiles-mode)
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "H" 'dired-hide-dotfiles-mode))

(use-package disk-usage
:commands (disk-usage))

(use-package recentf
  :ensure nil
  :hook (after-init . recentf-mode)
  :custom
  (recentf-auto-cleanup "05:00am")
  (recentf-max-saved-items 200)
  (recentf-exclude '((expand-file-name package-user-dir)
                     ".cache"
                     ".cask"
                     ".elfeed"
                     "bookmarks"
                     "cache"
                     "ido.*"
                     "persp-confs"
                     "recentf"
                     "undo-tree-hist"
                     "url"
                     "COMMIT_EDITMSG\\'")))

;; When buffer is closed, saves the cursor location
(save-place-mode 1)

;; Set history-length longer
(setq-default history-length 500)

;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 2 1000 1000))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(multiple-cursors yari yaml-mode which-key web-mode vterm visual-fill-column use-package typescript-mode toc-org smartparens rvm rust-mode ruby-tools rubocop robe rainbow-delimiters pyvenv python-mode plantuml-mode pdf-tools page-break-lines org-bullets no-littering lsp-ui lsp-ivy json-mode js2-mode ivy-rich ivy-prescient htmlize highlight-indent-guides helpful groovy-mode go-mode general format-all forge flyspell-correct-ivy flycheck-rust flycheck-posframe flycheck-popup-tip evil-nerd-commenter evil-collection eterm-256color eshell-git-prompt emmet-mode doom-themes doom-modeline dockerfile-mode docker disk-usage dired-single dired-open dired-hide-dotfiles diminish dashboard dap-mode counsel-projectile company-box command-log-mode auto-package-update all-the-icons-dired)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(avy-lead-face ((t (:background "#51afef" :foreground "#870000" :weight bold))))
 '(css-selector ((t (:inherit default :foreground "#66CCFF"))))
 '(cursor ((t (:background "BlanchedAlmond"))))
 '(dashboard-banner-logo-title ((t (:family "Love LetterTW" :height 123))))
 '(flycheck-posframe-face ((t (:foreground "#98be65"))))
 '(flycheck-posframe-info-face ((t (:foreground "#98be65"))))
 '(font-lock-comment-face ((t (:foreground "#828282")))))
