;;; lf-techlead.el --- Sprint & project management -*- lexical-binding: t; -*-
;;; Commentary:
;; Lean project management: Scrum sprints for work + personal projects.
;;
;; Files (created by M-x lf/init-project-files):
;;   ~/org/work.org      — MIMS project: sprints + backlog
;;   ~/org/personal.org  — pet projects + ideas
;;   ~/org/decisions.org — architecture/tech decision log (kept from before)
;;
;; Sprint workflow:
;;   1. M-x lf/work-new-sprint  — create sprint, enter number + start date
;;   2. Work tasks live under the sprint heading (tagged :current:)
;;   3. C-c c w  — capture a task directly into the current sprint
;;   4. C-c a s  — open sprint board (Kanban view: DOING → REVIEW → TODO → BACKLOG)
;;   5. M-x lf/work-new-sprint  — at sprint start, rotates :current: automatically
;;
;; Capture  (C-c c):
;;   w  work task → current sprint in work.org
;;   W  work backlog item → work.org Backlog
;;   x  personal task → personal.org
;;   i  idea → personal.org Ideas
;;   1  1-on-1 meeting note (Denote)
;;   D  decision log entry
;;
;; Agenda  (C-c a):
;;   s  Sprint board  (current sprint tasks grouped by state)
;;   x  Personal projects board
;;   R  Weekly review (cross-file: work + personal + inbox)

;;; Code:

;; ──────────────────────────────────────────────
;; File paths
;; ──────────────────────────────────────────────

(defcustom lf-work-file (expand-file-name "~/org/work.org")
  "Org file for work project (MIMS) sprints and backlog."
  :type 'string :group 'lf)

(defcustom lf-personal-file (expand-file-name "~/org/personal.org")
  "Org file for personal projects and ideas."
  :type 'string :group 'lf)

(defcustom lf-tl-decisions-file (expand-file-name "~/org/decisions.org")
  "Org file for architecture and technical decision log."
  :type 'string :group 'lf)

;; ──────────────────────────────────────────────
;; TODO states: sprint workflow
;; Appended to the GTD states defined in lf-org.el
;; ──────────────────────────────────────────────

(with-eval-after-load 'org
  (setq org-todo-keywords
        (append org-todo-keywords
                '((sequence "BACKLOG(b)" "DOING(g!)" "REVIEW(v!)" "|"
                            "DONE(d!)" "CANCELLED(c@)"))))
  (setq org-todo-keyword-faces
        (append org-todo-keyword-faces
                '(("BACKLOG" . (:foreground "#89b4fa" :weight bold))
                  ("DOING"   . (:foreground "#a6e3a1" :weight bold))
                  ("REVIEW"  . (:foreground "#fab387" :weight bold))))))

;; ──────────────────────────────────────────────
;; Sprint management
;; ──────────────────────────────────────────────

(defun lf/work-current-sprint ()
  "Return the org heading for the current sprint, or nil."
  (when (file-exists-p lf-work-file)
    (with-current-buffer (find-file-noselect lf-work-file)
      (save-excursion
        (goto-char (point-min))
        (when (re-search-forward "^\\*+ .+:current:" nil t)
          (org-get-heading t t t t))))))

(defun lf/work-new-sprint (number start-date)
  "Create Sprint NUMBER in `lf-work-file' starting on START-DATE.
Automatically removes :current: from the previous sprint.
Sprint length is 21 days (3 weeks).

After running this:
- The new sprint heading appears under * MIMS
- It is tagged :sprint:current: so agenda views find it
- Capture with `C-c c w' goes directly into this sprint"
  (interactive
   (list (read-number "Sprint number: ")
         (org-read-date nil nil nil "Sprint start date: ")))
  (find-file lf-work-file)
  ;; Remove :current: from previous sprint
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "^\\*+ " nil t)
      (org-back-to-heading t)
      (let ((tags (org-get-tags nil t)))
        (when (member "current" tags)
          (org-set-tags (remove "current" tags))))))
  ;; Compute dates
  (let* ((start-time (org-time-string-to-time start-date))
         (end-time   (time-add start-time (days-to-time 20)))
         (start-str  (format-time-string "[%Y-%m-%d %a]" start-time))
         (end-str    (format-time-string "<%Y-%m-%d %a>" end-time))
         (end-prop   (format-time-string "[%Y-%m-%d %a]" end-time)))
    ;; Insert new sprint after the MIMS heading's last child
    (goto-char (point-min))
    (unless (re-search-forward "^\\* MIMS" nil t)
      (goto-char (point-max))
      (insert "\n* MIMS\n"))
    (org-end-of-subtree nil t)
    (unless (bolp) (insert "\n"))
    (insert (format
             "** Sprint %d  :sprint:current:
   DEADLINE: %s
   :PROPERTIES:
   :SPRINT_START: %s
   :SPRINT_END:   %s
   :END:
"
             number end-str start-str end-prop)))
  (save-buffer)
  (message "Sprint %d created (%s). Use C-c c w to add tasks."
           number (lf/work-current-sprint)))

;; ──────────────────────────────────────────────
;; Capture: navigate to current sprint
;; Used as target by (function lf/--capture-to-sprint)
;; ──────────────────────────────────────────────

(defun lf/--capture-to-sprint ()
  "Position point inside the current sprint for org-capture.
Signals an error with instructions if no sprint is active."
  (find-file lf-work-file)
  (goto-char (point-min))
  (unless (re-search-forward ":current:" nil t)
    (user-error "No active sprint.  Run M-x lf/work-new-sprint first"))
  (org-back-to-heading t)
  (org-end-of-subtree nil t))

;; ──────────────────────────────────────────────
;; Capture templates
;; ──────────────────────────────────────────────

(with-eval-after-load 'org-capture
  (require 'denote nil t)
  (setq org-capture-templates
        (append org-capture-templates
                `(("w" "Work task → current sprint" entry
                   (function lf/--capture-to-sprint)
                   "*** TODO %^{Task}\n    SCHEDULED: %t\n%?"
                   :prepend t :empty-lines 1)

                  ("W" "Work backlog item" entry
                   (file+headline ,lf-work-file "Backlog")
                   "** BACKLOG %^{Task}\n%?"
                   :prepend t :empty-lines 1)

                  ("x" "Personal task" entry
                   (file+headline ,lf-personal-file "Inbox")
                   "** TODO %^{Task}\n%?"
                   :prepend t :empty-lines 1)

                  ("i" "Idea" entry
                   (file+headline ,lf-personal-file "Ideas")
                   "** %^{Idea}\n%?"
                   :prepend t :empty-lines 1)

                  ("1" "1-on-1 note (Denote)" plain
                   (file denote-last-path)
                   #'lf/denote-capture-1on1
                   :no-save t :kill-buffer t :jump-to-captured t)

                  ("D" "Decision log" entry
                   (file+olp+datetree ,lf-tl-decisions-file)
                   "* PROPOSED %^{Decision title}\n:PROPERTIES:\n:CREATED: %U\n:END:\n\n** Context\n%?\n\n** Options\n- \n\n** Decision\n"
                   :tree-type month :empty-lines 1)))))

;; ──────────────────────────────────────────────
;; Agenda views
;; ──────────────────────────────────────────────

(with-eval-after-load 'org-agenda
  ;; Remove old views registered by previous versions of this file
  (dolist (key '("T" "P" "W"))
    (setq org-agenda-custom-commands
          (assoc-delete-all key org-agenda-custom-commands)))

  ;; "s" — Sprint board: Kanban columns for the :current: sprint
  ;; Tag inheritance means tasks inside the :current: sprint inherit that tag
  (add-to-list 'org-agenda-custom-commands
               `("s" "Sprint board"
                 ((tags-todo "current+TODO=\"DOING\""
                             ((org-agenda-overriding-header "In Progress ──────────────────")
                              (org-agenda-files '(,lf-work-file))))
                  (tags-todo "current+TODO=\"REVIEW\""
                             ((org-agenda-overriding-header "In Review ────────────────────")
                              (org-agenda-files '(,lf-work-file))))
                  (tags-todo "current+TODO=\"TODO\""
                             ((org-agenda-overriding-header "To Do ────────────────────────")
                              (org-agenda-files '(,lf-work-file))))
                  (tags-todo "current+TODO=\"BACKLOG\""
                             ((org-agenda-overriding-header "Backlog (top 10) ─────────────")
                              (org-agenda-files '(,lf-work-file))
                              (org-agenda-max-entries 10))))
                 nil nil))

  ;; "x" — Personal projects board
  (add-to-list 'org-agenda-custom-commands
               `("x" "Personal projects"
                 ((todo "DOING\\|NEXT\\|TODO"
                        ((org-agenda-overriding-header "Active ───────────────────────")
                         (org-agenda-files '(,lf-personal-file))))
                  (todo "BACKLOG"
                        ((org-agenda-overriding-header "Backlog ──────────────────────")
                         (org-agenda-files '(,lf-personal-file))
                         (org-agenda-max-entries 15))))
                 nil nil))

  ;; "R" — Weekly review: full-week agenda + blockers + sprint backlog
  (add-to-list 'org-agenda-custom-commands
               `("R" "Weekly review"
                 ((agenda ""
                          ((org-agenda-span 'week)
                           (org-agenda-start-with-log-mode t)
                           (org-agenda-files '(,lf-work-file
                                               ,lf-personal-file
                                               "~/org/inbox.org"))))
                  (tags-todo "current+TODO=\"REVIEW\""
                             ((org-agenda-overriding-header "Waiting for review:")
                              (org-agenda-files '(,lf-work-file))))
                  (todo "WAITING"
                        ((org-agenda-overriding-header "Blocked / waiting:")
                         (org-agenda-files '(,lf-work-file
                                             ,lf-personal-file
                                             "~/org/inbox.org"))))
                  (todo "BACKLOG"
                        ((org-agenda-overriding-header "Sprint backlog (unstarted):")
                         (org-agenda-files '(,lf-work-file))
                         (org-agenda-max-entries 10))))
                 nil nil)))

;; ──────────────────────────────────────────────
;; Denote helper: 1-on-1 note
;; ──────────────────────────────────────────────

(defun lf/denote-capture-1on1 ()
  "Denote capture for 1-on-1 meeting notes with structured sections."
  (let ((denote-use-keywords '("1on1"))
        (denote-use-template
         "** Updates from last time\n- [ ] \n\n** Topics\n- \n\n** Action Items\n- [ ] \n\n** Notes\n"))
    (denote-org-capture)))

;; ──────────────────────────────────────────────
;; File initializer — run once
;; ──────────────────────────────────────────────

(defun lf/init-project-files ()
  "Create work.org, personal.org, decisions.org if they don't exist.
Run once: M-x lf/init-project-files

work.org structure:
  * MIMS
  ** Backlog         ← unscheduled items waiting for a sprint
  (sprints added by lf/work-new-sprint)

personal.org structure:
  * Projects         ← pet projects, improvement tasks
  ** Inbox           ← captures land here; refile to project subheadings
  * Ideas            ← low-friction idea dump"
  (interactive)
  (dolist (spec
           `((,lf-work-file
              "#+title: MIMS — Work\n#+startup: overview\n\n* MIMS\n** Backlog\n")
             (,lf-personal-file
              "#+title: Personal Projects & Ideas\n#+startup: overview\n\n* Projects\n** Inbox\n* Ideas\n")
             (,lf-tl-decisions-file
              "#+title: Technical Decisions\n#+startup: overview\n\n")))
    (let ((file (car spec))
          (content (cadr spec)))
      (if (file-exists-p file)
          (message "Skipped (exists): %s" file)
        (with-temp-file file (insert content))
        (message "Created: %s" file)))))

(provide 'lf-techlead)
;;; lf-techlead.el ends here
