;;; lf-keys.el --- Global keybindings and hydra menus -*- lexical-binding: t; -*-
;;; Commentary:
;; Defines global keybindings and hydra menus.
;; All custom bindings live here for easy reference.
;;
;; Keybinding summary:
;;
;; Navigation:
;;   M-j            avy-goto-char-timer          (lf-prog)
;;   M-i            dired side panel             (lf-prog)
;;   M-g o          dumb-jump-go-other-window    (lf-prog)
;;   M-g j          dumb-jump-go                 (lf-prog)
;;   M-g b          dumb-jump-back               (lf-prog)
;;   [remap other-window] ace-window             (lf-prog)
;;
;; Buffers:
;;   C-x C-b        ibuffer
;;   M-s i          imenu
;;
;; Lines:
;;   M-<up>         move-line-up                 (lf-core)
;;   M-<down>       move-line-down               (lf-core)
;;   M-p            move-line-up                 (lf-core)
;;   M-n            move-line-down               (lf-core)
;;
;; Editing:
;;   C->            mc/mark-next-like-this       (lf-prog)
;;   C-<            mc/mark-previous-like-this   (lf-prog)
;;   C-c C-<        mc/mark-all-like-this        (lf-prog)
;;
;; Git:
;;   C-x g          magit-status                 (lf-prog)
;;
;; Completion / help:
;;   C-h f          helpful-callable             (lf-completion)
;;   C-h v          helpful-variable             (lf-completion)
;;   C-h k          helpful-key                  (lf-completion)
;;   C-h x          helpful-command              (lf-completion)
;;   C-h F          helpful-function             (lf-completion)
;;   C-c C-d        helpful-at-point             (lf-completion)
;;
;; Search (consult):
;;   C-x b          consult-buffer               (lf-completion)
;;   M-y            consult-yank-pop             (lf-completion)
;;   M-s r          consult-ripgrep              (lf-completion)
;;   M-s l          consult-line                 (lf-completion)
;;   M-g i          consult-imenu                (lf-completion)
;;
;; Shell:
;;   C-c e          eshell                       (lf-shell)
;;
;; Notes (denote):
;;   C-c n n        denote                       (lf-org)
;;   C-c n f        consult-denote-find          (lf-org)
;;   C-c n g        consult-denote-grep          (lf-org)
;;
;; AI (gptel):
;;   C-c SPC g      gptel                        (lf-ai)
;;   C-c SPC s      gptel-send                   (lf-ai)
;;   C-c SPC m      gptel-menu                   (lf-ai)
;;   C-c SPC 1      switch to Claude             (lf-ai)
;;   C-c SPC 2      switch to GPT-4             (lf-ai)
;;   C-c SPC q      quick query                 (lf-ai)
;;   C-c SPC e      explain code                (lf-ai)
;;   C-c SPC i      improve writing             (lf-ai)
;;   C-c SPC S      summarize                   (lf-ai)
;;
;; Org capture:
;;   C-c c          org-capture
;;   C-c a          org-agenda
;;
;; Tech lead (hydra-techlead):
;;   C-c l          hydra-techlead/body         (lf-techlead)
;;     t            org-agenda "T" — team overview
;;     p            org-agenda "P" — projects board
;;     w            org-agenda "W" — weekly review
;;     1            org-capture "1" — 1-on-1 note (Denote)
;;     b            org-capture "b" — backlog item
;;     D            org-capture "D" — decision log
;;     f            org-capture "f" — dev feedback
;;     k            org-capture "k" — blocked item
;;     P            find-file projects.org
;;     T            find-file team.org
;;     d            find-file decisions.org
;;
;; Bookmarks (arrow):
;;   C-c b a        arrow-add                   (lf-prog)
;;   C-c b s        arrow-show                  (lf-prog)
;;   C-c b n        arrow-next-line             (lf-prog)
;;   C-c b p        arrow-prev-line             (lf-prog)
;;   C-c b j        arrow-jump (unified)        (lf-prog)
;;   C-c b P        arrow-project-add           (lf-prog)
;;   C-c b N        arrow-project-next          (lf-prog)
;;   C-c b v        arrow-project-prev          (lf-prog)
;;
;; Misc:
;;   C-x /          webjump                     (lf-web)
;;   <f9>           hydra-zoom/body
;;   C-c y          my/copy-buffer-file-path-to-clipboard

;;; Code:


;; Silence undefined hardware keys
(global-set-key (kbd "<XF86MonBrightnessUp>") #'ignore)
(global-set-key (kbd "<XF86MonBrightnessDown>") #'ignore)
(global-set-key (kbd "C-<XF86MonBrightnessUp>") #'ignore)
(global-set-key (kbd "C-<XF86MonBrightnessDown>") #'ignore)
(global-set-key (kbd "M-<XF86MonBrightnessUp>") #'ignore)
(global-set-key (kbd "M-<XF86MonBrightnessDown>") #'ignore)

;; ──────────────────────────────────────────────
;; Hydra
;; ──────────────────────────────────────────────

(use-package hydra
  :ensure t)

(use-package pretty-hydra
  :ensure t
  :after hydra
  :config
  (pretty-hydra-define hydra-zoom
    (:hint nil :title "✦ Zoom Control")
    ("Zoom"
     (("j" text-scale-increase "Zoom In +")
      ("k" text-scale-decrease "Zoom Out -")
      ("0" (text-scale-set 0)  "Reset")
      ("q" nil                 "Quit"))))
  (pretty-hydra-define hydra-techlead
    (:hint nil :title "⚙ Tech Lead" :quit-key "q")
    ("Agenda"
     (("t" (org-agenda nil "T") "Team overview"    :exit t)
      ("p" (org-agenda nil "P") "Projects board"   :exit t)
      ("w" (org-agenda nil "W") "Weekly review"    :exit t))
     "Capture"
     (("1" (org-capture nil "1") "1-on-1 note"    :exit t)
      ("b" (org-capture nil "b") "Backlog item"   :exit t)
      ("D" (org-capture nil "D") "Decision log"   :exit t)
      ("f" (org-capture nil "f") "Dev feedback"   :exit t)
      ("k" (org-capture nil "k") "Blocked item"   :exit t))
     "Files"
     (("P" (find-file lf-tl-projects-file)  "projects.org"  :exit t)
      ("T" (find-file lf-tl-team-file)      "team.org"      :exit t)
      ("d" (find-file lf-tl-decisions-file) "decisions.org" :exit t))))
  :bind (("<f9>"  . hydra-zoom/body)
         ("C-c l" . hydra-techlead/body)))

;; ──────────────────────────────────────────────
;; Global bindings
;; ──────────────────────────────────────────────

;; Buffer list
(global-set-key (kbd "C-x C-b") #'ibuffer)

;; Imenu
(global-set-key (kbd "M-s i") #'imenu)

;; Move lines
(global-set-key (kbd "M-<up>")   #'move-line-up)
(global-set-key (kbd "M-<down>") #'move-line-down)
(global-set-key (kbd "M-p")      #'move-line-up)
(global-set-key (kbd "M-n")      #'move-line-down)

;; Copy buffer path
(global-set-key (kbd "C-c y") #'my/copy-buffer-file-path-to-clipboard)

;; Org agenda and capture
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

;; ──────────────────────────────────────────────
;; Tech lead hydra  (C-c l)
;; ──────────────────────────────────────────────


(provide 'lf-keys)
;;; lf-keys.el ends here
