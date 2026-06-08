;;; lf-org.el --- Org-mode, Denote notes, presentations -*- lexical-binding: t; -*-
;;; Commentary:
;; Full Org-mode config, Denote note-taking, org-capture templates,
;; org-present, mermaid/plantuml/restclient babel, ox-latex, ox-gfm.

;;; Code:

;; ──────────────────────────────────────────────
;; Org-mode base configuration
;; ──────────────────────────────────────────────

(use-package org
  :ensure nil
  :defer t
  :mode ("\\.org\\'" . org-mode)
  :bind (("C-c a" . org-agenda)
         ("C-c c" . org-capture))
  :config
  (setq
   org-startup-folded t
   org-auto-align-tags nil
   org-tags-column 0
   org-fold-catch-invisible-edits 'show-and-error
   org-special-ctrl-a/e t
   org-insert-heading-respect-content t
   org-hide-emphasis-markers t
   org-pretty-entities t
   org-use-sub-superscripts nil
   org-hide-leading-stars t
   org-agenda-files '("~/org/inbox.org"
		      "~/org/work.org"
		      "~/org/decisions.org"
		      "~/org/calendar.org")
   org-todo-keywords
   '((sequence "TODO(t)" "NEXT(n)" "WAITING(w@/!)" "|" "DONE(d!)" "CANCELLED(c@)"))
   org-todo-keyword-faces
   '(("TODO"      . (:foreground "#ff6b6b" :weight bold))
     ("NEXT"      . (:foreground "#feca57" :weight bold))
     ("WAITING"   . (:foreground "#a29bfe" :weight bold))
     ("DONE"      . (:foreground "#6ab04c" :weight bold))
     ("CANCELLED" . (:foreground "#636e72" :weight bold)))
   org-log-done 'time
   org-log-into-drawer t
   org-refile-targets '((nil :maxlevel . 3)
                        (org-agenda-files :maxlevel . 3))
   org-refile-use-outline-path 'file
   org-outline-path-complete-in-steps nil
   org-refile-allow-creating-parent-nodes 'confirm
   org-agenda-tags-column 0
   org-agenda-block-separator ?─
   org-agenda-time-grid
   '((daily today require-timed)
     (800 1000 1200 1400 1600 1800 2000)
     " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
   org-agenda-current-time-string
   "◀── now ─────────────────────────────────────────────────"
   org-agenda-start-with-log-mode t)
  (setq org-ellipsis " ▼ ")
  (set-face-attribute 'org-ellipsis nil :inherit 'default :box nil))

;; ──────────────────────────────────────────────
;; org-modern — bullets, todo, tags, tables
;; ──────────────────────────────────────────────

(use-package org-modern
  :ensure t
  :hook (org-mode . org-modern-mode)
  :custom
  (org-modern-star '("◉" "○" "◈" "◇" "▷"))
  (org-modern-table t)
  (org-modern-tag t)
  (org-modern-todo t))

;; ──────────────────────────────────────────────
;; org-appear
;; ──────────────────────────────────────────────

(use-package org-appear
  :ensure t
  :hook (org-mode . org-appear-mode)
  :custom
  (org-appear-autoemphasis t)
  (org-appear-autolinks t)
  (org-appear-autosubmarkers t)
  (org-appear-autoentities t)
  (org-appear-delay 0.2))

;; ──────────────────────────────────────────────
;; Denote — note-taking
;; ──────────────────────────────────────────────

(use-package denote
  :ensure t
  :hook
  ((text-mode  . denote-fontify-links-mode)
   (dired-mode . denote-dired-mode))
  :bind
  (("C-c n n" . denote)
   ("C-c n N" . denote-type)
   ("C-c n o" . denote-open-or-create)
   ("C-c n d" . denote-sort-dired)
   ("C-c n r" . denote-rename-file)
   ("C-c n i" . denote-link-or-create)
   :map text-mode-map
   ("C-c n l" . denote-link)
   ("C-c n L" . denote-add-links)
   ("C-c n b" . denote-backlinks)
   ("C-c n R" . denote-rename-file-using-front-matter)
   :map dired-mode-map
   ("C-c C-d C-i" . denote-dired-link-marked-notes)
   ("C-c C-d C-r" . denote-dired-rename-files)
   ("C-c C-d C-k" . denote-dired-rename-marked-files-with-keywords)
   ("C-c C-d C-f" . denote-dired-rename-marked-files-using-front-matter))
  :custom
  (denote-directory (expand-file-name "~/org/denotes/"))
  (denote-file-type 'org)
  (denote-infer-keywords t)
  (denote-sort-keywords t)
  (denote-save-buffers nil)
  (denote-prompts '(title keywords))
  (denote-rename-confirmations '(rewrite-front-matter modify-file-name))
  (denote-date-prompt-use-org-read-date t)
  (denote-backlinks-show-context t)
  :config
  (denote-rename-buffer-mode 1))

(use-package consult-denote
  :ensure t
  :bind (("C-c n f" . consult-denote-find)
         ("C-c n g" . consult-denote-grep))
  :config
  (consult-denote-mode 1))

(use-package denote-menu
  :ensure t
  :bind (("C-c n m" . list-denotes)))

(use-package denote-search
  :ensure t
  :bind (("C-c n s" . denote-search)))

;; ──────────────────────────────────────────────
;; Denote Journal — separate package, daily notes
;; ──────────────────────────────────────────────

(use-package denote-journal
  :ensure (:host github :repo "protesilaos/denote-journal")
  :after denote
  :bind (("C-c n j" . denote-journal-new-or-existing-entry)
         ("C-c n J" . denote-journal-new-entry))
  :custom
  (denote-journal-directory (expand-file-name "~/org/denotes/journal/"))
  (denote-journal-keyword "journal")
  (denote-journal-title-format "%A %e %B %Y")   ; e.g. "Monday 15 January 2024"
  :config
  (make-directory denote-journal-directory t)
  ;; Include journal dir in org-agenda: TODOs appear in calendar view.
  ;; org-agenda-files does NOT scan subdirectories recursively,
  ;; so we must add this explicitly even though ~/org is listed.
  (add-to-list 'org-agenda-files denote-journal-directory t))

;; ──────────────────────────────────────────────
;; Org-agenda: journal + calendar custom views
;; ──────────────────────────────────────────────

(with-eval-after-load 'org-agenda
  ;; "j" — today's journal view: agenda + tasks from journal dir only
  (add-to-list 'org-agenda-custom-commands
               `("j" "Journal: today + tasks"
                 ((agenda ""
                          ((org-agenda-span 'day)
                           (org-agenda-start-with-log-mode t)
                           (org-agenda-log-mode-items '(clock closed state))))
                  (todo "NEXT|TODO"
                        ((org-agenda-files
                          (list ,(expand-file-name "~/org/denotes/journal/")))
                         (org-agenda-overriding-header "Journal TODOs:"))))
                 nil nil))
  ;; "w" — weekly review: full week + all journal TODOs
  (add-to-list 'org-agenda-custom-commands
               `("w" "Weekly review"
                 ((agenda ""
                          ((org-agenda-span 'week)
                           (org-agenda-start-with-log-mode t)))
                  (todo "WAITING"
                        ((org-agenda-overriding-header "Waiting:")))
                  (todo "NEXT"
                        ((org-agenda-overriding-header "Next actions:"))))
                 nil nil)))

;; ──────────────────────────────────────────────
;; Denote capture helpers
;; ──────────────────────────────────────────────

(defun lf/denote-capture-meeting ()
  "Org capture body: Denote note with 'meeting' keyword preset and structured sections.
`denote-use-keywords' and `denote-use-template' are the idiomatic Denote API
for injecting values without prompting.  Only the title is prompted."
  (let ((denote-use-keywords '("meeting"))
        (denote-use-template "** Attendees\n- \n\n** Agenda\n\n** Action Items\n- [ ] "))
    (denote-org-capture)))

(defun lf/denote-capture-project ()
  "Org capture body: Denote note with 'project' keyword preset and structured sections.
`denote-use-keywords' and `denote-use-template' are the idiomatic Denote API
for injecting values without prompting.  Only the title is prompted."
  (let ((denote-use-keywords '("project"))
        (denote-use-template "** Goal\n\n** Tasks\n- [ ] \n\n** Notes\n"))
    (denote-org-capture)))

;; ──────────────────────────────────────────────
;; Org capture templates
;; ──────────────────────────────────────────────

(with-eval-after-load 'org-capture
  (require 'denote)
  (setq org-capture-templates
        `(("n" "New note (Denote)" plain
           (file denote-last-path)
           #'denote-org-capture
           :no-save t :kill-buffer t :jump-to-captured t)
          ("t" "Task to Inbox" entry
           (file "~/org/inbox.org")
           "* TODO %?\n  %U\n  %a"
           :empty-lines 1)
          ("m" "Meeting Note" plain
           (file denote-last-path)
           #'lf/denote-capture-meeting
           :no-save t :kill-buffer t :jump-to-captured t)
          ("p" "Project Note" plain
           (file denote-last-path)
           #'lf/denote-capture-project
           :no-save t :kill-buffer t :jump-to-captured t)
          ("d" "Daily Log" entry
           (file+olp+datetree "~/org/denotes/daily.org")
           "* %<%H:%M> %?"
           :tree-type week :empty-lines 1)
          ("r" "Note" entry
           (file ,my-org-inbox-file)
           "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n\n%i\n\n- %a"
           :prepend t)
          ("c" "Contents to current clock task" plain (clock)
           "%i%?\n%a" :empty-lines 1)
          ("." "Today" entry
           (file ,my-org-inbox-file)
           "* TODO %^{Task}\nSCHEDULED: %t\n:PROPERTIES:\n:CREATED: %U\n:END:\n"
           :immediate-finish t))))

;; ──────────────────────────────────────────────
;; Org modules
;; ──────────────────────────────────────────────

(with-eval-after-load 'org
  (setq org-modules '(org-habit org-mouse ol-info org-protocol))
  (org-load-modules-maybe t))

;; ──────────────────────────────────────────────
;; Presentation: visual-fill-column + org-present
;; ──────────────────────────────────────────────

(use-package visual-fill-column
  :ensure t
  :defer t
  :custom
  (visual-fill-column-width 110)
  (visual-fill-column-center-text t))

(defun my/org-present-start ()
  "Set up large font presentation view."
  (face-remap-add-relative 'default :height 1.5 'variable-pitch)
  (face-remap-add-relative 'org-document-title '((:height 2.0 :weight bold) variable-pitch))
  (face-remap-add-relative 'org-document-info  '((:height 1.5) variable-pitch))
  (face-remap-add-relative 'org-level-1 :height 1.7 :weight 'bold)
  (face-remap-add-relative 'org-level-2 :height 1.5 :weight 'bold)
  (face-remap-add-relative 'org-level-3 :height 1.3 :weight 'bold)
  (face-remap-add-relative 'org-level-4 :height 1.2 :weight 'bold)
  (face-remap-add-relative 'org-level-5 :height 1.1 :weight 'bold)
  (face-remap-add-relative 'org-level-6 :height 1.1 :weight 'semi-bold)
  (face-remap-add-relative 'org-level-7 :height 1.05 :weight 'semi-bold)
  (face-remap-add-relative 'org-level-8 :height 1.05 :weight 'semi-bold)
  (face-remap-add-relative 'org-code :height 1.1)
  (face-remap-add-relative 'org-verbatim :height 1.1)
  (face-remap-add-relative 'org-block :height 1.1)
  (face-remap-add-relative 'org-block-begin-line :height 0.8)
  (setq header-line-format " ")
  (org-display-inline-images)
  (display-line-numbers-mode 0)
  (setq-local visual-fill-column-width 110
              visual-fill-column-center-text t
              left-margin-width 2
              right-margin-width 2)
  (set-window-buffer nil (current-buffer))
  (visual-fill-column-mode 1)
  (visual-line-mode 1)
  (recenter))

(defun my/org-present-end ()
  "Restore normal view after presentation."
  (setq-local face-remapping-alist nil)
  (setq header-line-format nil)
  (org-remove-inline-images)
  (display-line-numbers-mode 1)
  (visual-fill-column-mode 0)
  (visual-line-mode 0))

(defun my/org-present-prepare-slide (_buffer-name _heading)
  "Show current slide cleanly."
  (org-overview)
  (org-fold-show-entry)
  (org-fold-show-children))

(defun my/org-present-image-zoom-in ()
  "Zoom in on inline images."
  (interactive)
  (setq-local org-image-actual-width
              (+ (or org-image-actual-width 400) 100))
  (org-redisplay-inline-images))

(defun my/org-present-image-zoom-out ()
  "Zoom out on inline images."
  (interactive)
  (setq-local org-image-actual-width
              (max 100 (- (or org-image-actual-width 500) 100)))
  (org-redisplay-inline-images))

(use-package org-present
  :ensure t
  :commands (org-present)
  :after org
  :bind (:map org-present-mode-keymap
              ("C-x ]" . org-present-next)
              ("C-x [" . org-present-prev)
              ("C-c +" . my/org-present-image-zoom-in)
              ("C-c -" . my/org-present-image-zoom-out)))

(add-hook 'org-present-mode-hook           #'my/org-present-start)
(add-hook 'org-present-mode-quit-hook      #'my/org-present-end)
(add-hook 'org-present-after-navigate-functions #'my/org-present-prepare-slide)


;; ──────────────────────────────────────────────
;; org-re-reveal — Export org → Reveal.js HTML slides
;; (actively maintained fork of ox-reveal)
;; ──────────────────────────────────────────────

(use-package org-re-reveal
  :ensure t
  :after org
  :custom
  (org-re-reveal-root "https://cdn.jsdelivr.net/npm/reveal.js@6/")
  (org-re-reveal-revealjs-version "6")          ; reveal.js 6.x
  (org-re-reveal-theme "moon")
  (org-re-reveal-transition "slide")
  (org-re-reveal-mathjax t)
  (org-re-reveal-title-slide "<h1>%t</h1><h3>%a</h3><p><small>%d</small></p>")
  :config
  (require 'org-re-reveal)
  ;; Plugins dùng org-re-reveal-plugin-6-config cho v6 (khác v4/v5)
  (setq org-re-reveal-plugin-6-config
        '((highlight "RevealHighlight" "plugin/highlight/highlight.js")
          (notes     "RevealNotes"     "plugin/notes/notes.js")
          (search    "RevealSearch"    "plugin/search/search.js")
          (zoom      "RevealZoom"      "plugin/zoom/zoom.js"))))
;; ──────────────────────────────────────────────
;; Mermaid diagrams
;; ──────────────────────────────────────────────

(use-package mermaid-mode
  :ensure t
  :mode "\\.mmd\\'"
  :config
  (setq mermaid-mmdc-location
        (or (executable-find "mmdc")
            (expand-file-name "~/.asdf/shims/mmdc")
            (expand-file-name "~/.npm-global/bin/mmdc")
            (expand-file-name "~/.local/bin/mmdc")
            "/usr/local/bin/mmdc")))

;; Tell elpaca to install ob-mermaid and ox-gfm, then wait for both
;; to be built and activated before any require attempt.
(use-package ob-mermaid :ensure t :defer t)
(use-package ox-gfm    :ensure t :defer t)
(elpaca-wait)

;; Configure after elpaca has put them on load-path
(with-eval-after-load 'org
  (setq ob-mermaid-cli-path (expand-file-name "~/.local/bin/mmdc-wrapper"))
  (require 'ob-mermaid nil t)
  (add-to-list 'org-babel-load-languages '(mermaid . t))
  (org-babel-do-load-languages 'org-babel-load-languages org-babel-load-languages)
  (require 'ox-gfm nil t))

;; ──────────────────────────────────────────────
;; PlantUML
;; ──────────────────────────────────────────────

(use-package plantuml-mode
  :ensure t
  :mode ("\\.puml\\'" "\\.plantuml\\'")
  :custom
  (plantuml-default-exec-mode 'jar)
  (plantuml-jar-path (expand-file-name "~/.config/emacs/plantuml.jar"))
  (plantuml-output-type "png")
  (plantuml-indent-level 2))

;; ──────────────────────────────────────────────
;; Org babel languages
;; ──────────────────────────────────────────────

(with-eval-after-load 'org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (shell      . t)
     (ruby       . t)
     (plantuml   . t)
     (dot        . t)
     (sql        . t)))
  (setq org-confirm-babel-evaluate nil
        org-babel-results-keyword "RESULTS"
        org-plantuml-jar-path (expand-file-name "~/.config/emacs/plantuml.jar")
        org-plantuml-exec-mode 'jar))

;; ──────────────────────────────────────────────
;; restclient + ob-restclient
;; ──────────────────────────────────────────────

(use-package restclient
  :ensure t
  :mode ("\\.rest\\'" . restclient-mode))

(use-package ob-restclient
  :ensure t
  :after (org restclient)
  :config
  (add-to-list 'org-babel-load-languages '(restclient . t))
  (org-babel-do-load-languages 'org-babel-load-languages org-babel-load-languages))

;; ──────────────────────────────────────────────
;; LaTeX export (ox-latex)
;; ──────────────────────────────────────────────

(use-package ox-latex
  :ensure nil
  :after org)

(with-eval-after-load 'ox-latex
  (setq org-latex-compiler "xelatex"
        org-latex-pdf-process
        '("xelatex -interaction nonstopmode -output-directory %o %f"
          "xelatex -interaction nonstopmode -output-directory %o %f")
        org-latex-hyperref-template nil)
  (setq org-latex-default-packages-alist
        (cl-remove-if (lambda (pkg)
                        (member (cadr pkg) '("inputenc" "fontenc" "hyperref")))
                      org-latex-default-packages-alist))
  (add-to-list 'org-latex-classes
               '("moderncv"
                 "\\documentclass{moderncv}"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}"))))

;; ──────────────────────────────────────────────
;; pdf-tools + AUCTeX
;; ──────────────────────────────────────────────

(use-package pdf-tools
  :ensure t
  :defer t
  :config
  (pdf-tools-install)
  (setq-default pdf-view-display-size 'fit-width))

(use-package auctex
  :ensure t
  :defer t
  :hook (LaTeX-mode . TeX-source-correlate-mode)
  :config
  (setq TeX-auto-save t
        TeX-parse-self t
        TeX-save-query nil
        TeX-PDF-mode t
        TeX-command-default "LatexMk")
  (add-hook 'LaTeX-mode-hook
            (lambda ()
              (unless (assoc "LatexMk" TeX-command-list)
                (add-to-list 'TeX-command-list
                             '("LatexMk" "latexmk -pdf -interaction=nonstopmode %s"
                               TeX-run-TeX nil t :help "Run latexmk")))))
  (setq TeX-view-program-selection
        '((output-pdf "PDF Tools")
          (output-dvi "xdvi")
          (output-html "xdg-open"))
        TeX-view-program-list '(("PDF Tools" TeX-pdf-tools-sync-view)))
  (add-hook 'LaTeX-mode-hook
            (lambda ()
              (turn-on-reftex)
              (setq reftex-plug-into-AUCTeX t)))
  (add-hook 'LaTeX-mode-hook #'flymake-mode)
  (setq preview-auto-cache-preamble t
        preview-image-type 'dvipng
        preview-auto-reveal t
        preview-scale-function 1.2
        preview-scale-by 1.2))

;; GPTel org-mode integration
(with-eval-after-load 'org
  (add-hook 'org-mode-hook
            (lambda ()
              (setq-local gptel-default-mode 'org-mode))))

(provide 'lf-org)
;;; lf-org.el ends here
