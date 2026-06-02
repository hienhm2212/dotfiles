;;; lf-web.el --- Browser and RSS feeds -*- lexical-binding: t; -*-
;;; Commentary:
;; EWW (built-in browser), engine-mode (search engines),
;; webjump (quick URL navigation), Elfeed (RSS/Atom reader).

;;; Code:

;; ──────────────────────────────────────────────
;; EWW — built-in browser
;; ──────────────────────────────────────────────

(use-package eww
  :ensure nil
  :defer t
  :config
  (setq eww-search-prefix "https://google.com/search?q="))

;; ──────────────────────────────────────────────
;; engine-mode — search from Emacs
;; ──────────────────────────────────────────────

(use-package engine-mode
  :ensure t
  :defer t
  :config
  (engine-mode 1)
  (defengine google "https://www.google.com/search?q=%s" :keybinding "g")
  (defengine github "https://github.com/search?q=%s"     :keybinding "h"))

;; ──────────────────────────────────────────────
;; webjump — quick URL access
;; ──────────────────────────────────────────────

(use-package webjump
  :ensure nil
  :defer t
  :bind ("C-x /" . webjump)
  :custom
  (webjump-sites
   '(("Google"  . [simple-query "www.google.com"   "www.google.com/search?q=" ""])
     ("YouTube" . [simple-query "www.youtube.com"  "www.youtube.com/results?search_query=" ""])
     ("ChatGPT" . [simple-query "https://chatgpt.com" "https://chatgpt.com/?q=" ""]))))

;; ──────────────────────────────────────────────
;; Elfeed — RSS/Atom feed reader
;; ──────────────────────────────────────────────

(use-package elfeed
  :ensure t
  :defer t
  :commands elfeed)

(use-package elfeed-org
  :ensure t
  :config
  (setq rmh-elfeed-org-files (list (expand-file-name "~/.config/emacs/feeds.org")))
  (with-eval-after-load 'elfeed
    (elfeed-org)
    (add-hook 'after-save-hook #'elfeed-org-update-db-if-changed 'nil 'local)))

(use-package elfeed-goodies
  :ensure t
  :after elfeed
  :config
  (elfeed-goodies/setup)
  (setq elfeed-goodies-entry-title-style '(title tags date)))

(use-package elfeed-tube
  :ensure t
  :after elfeed
  :config
  (elfeed-tube-setup))

(provide 'lf-web)
;;; lf-web.el ends here
