;;; lf-ai.el --- LLM client (GPTel) -*- lexical-binding: t; -*-
;;; Commentary:
;; GPTel configured with OpenAI (default) and Claude backends.
;; API keys loaded from ~/.authinfo.gpg via auth-source.
;; Keybindings under C-c SPC prefix.

;;; Code:

(use-package gptel
  :ensure t
  :demand t
  :config
  ;; OpenAI backend (default)
  (setq gptel-backend
        (gptel-make-openai "ChatGPT"
          :stream t
          :key (lambda ()
                 (or (auth-source-pick-first-password :host "api.openai.com")
                     (user-error "No OpenAI API key found in authinfo")))
          :models '("gpt-4.1"
                    "gpt-4.1-mini"
                    "gpt-4o")))
  (setq gptel-model 'gpt-4.1)

  ;; Claude backend
  (gptel-make-anthropic "Claude"
    :stream t
    :key (lambda ()
           (or (auth-source-pick-first-password :host "api.anthropic.com")
               (user-error "No Anthropic API key found in authinfo"))))

  ;; General settings
  (setq gptel-default-mode 'org-mode
        gptel-stream t)

  ;; Prompt/response prefixes
  (setq gptel-prompt-prefix-alist
        '((markdown-mode . "### ")
          (org-mode      . "* ")
          (text-mode     . "### ")))
  (setq gptel-response-prefix-alist
        '((markdown-mode . "")
          (org-mode      . "")
          (text-mode     . "")))

  ;; System directives
  (setq gptel-directives
        '((default      . "You are a helpful assistant. Be concise and accurate.")
          (programming  . "You are an expert programmer. Provide clean, efficient code with explanations. Focus on best practices and readability.")
          (emacs-expert . "You are an Emacs Lisp expert. Help with Emacs configuration, packages, and customization. Provide working code examples.")
          (writing      . "You are a professional editor and writing coach. Help improve clarity, grammar, and style while maintaining the author's voice.")
          (explain      . "You are a teacher. Explain concepts clearly with examples and analogies suitable for learners.")
          (code-review  . "You are a senior code reviewer. Analyze code for bugs, performance issues, security vulnerabilities, and suggest improvements.")
          (translator   . "You are a professional translator. Provide accurate, natural-sounding translations while preserving meaning and tone.")
          (creative     . "You are a creative writing assistant. Help brainstorm ideas, develop narratives, and craft engaging content.")
          (debug        . "You are a debugging expert. Analyze code or error messages and provide step-by-step solutions.")))
  (setq gptel-directive 'default)

  :bind (("C-c SPC g" . gptel)
         ("C-c SPC s" . gptel-send)
         ("C-c SPC r" . gptel-rewrite-menu)
         ("C-c SPC m" . gptel-menu)
         ("C-c SPC a" . gptel-add)
         ("C-c SPC d" . gptel-set-directive)
         ("C-c SPC b" . gptel-set-backend)
         :map gptel-mode-map
         ("C-c RET"   . gptel-send)))

;; ──────────────────────────────────────────────
;; Helper functions
;; ──────────────────────────────────────────────

(defun my/gptel-quick-query (prompt)
  "Quick one-off query to LLM without opening a chat buffer."
  (interactive "sPrompt: ")
  (gptel-request
      prompt
    :callback
    (lambda (response info)
      (if (not response)
          (message "gptel error: %s" (plist-get info :status))
        (with-current-buffer (get-buffer-create "*gptel-response*")
          (erase-buffer)
          (insert response)
          (goto-char (point-min))
          (display-buffer (current-buffer)))))))

(defun my/gptel-explain-code ()
  "Explain the selected code or function at point."
  (interactive)
  (let ((code (if (region-active-p)
                  (buffer-substring-no-properties (region-beginning) (region-end))
                (thing-at-point 'defun t))))
    (when code
      (gptel-request
          (format "Explain this code:\n\n```\n%s\n```" code)
        :system "You are a code explanation expert. Explain clearly and concisely."
        :callback
        (lambda (response _info)
          (when response
            (with-current-buffer (get-buffer-create "*Code Explanation*")
              (erase-buffer)
              (insert response)
              (goto-char (point-min))
              (markdown-mode)
              (display-buffer (current-buffer)))))))))

(defun my/gptel-improve-writing ()
  "Improve selected text for clarity and grammar."
  (interactive)
  (when (region-active-p)
    (let ((text (buffer-substring-no-properties (region-beginning) (region-end))))
      (gptel-request
          (format "Improve this text for clarity, grammar, and style:\n\n%s" text)
        :system "You are a professional editor. Improve the text while maintaining the original meaning and voice."
        :callback
        (lambda (response _info)
          (when response
            (kill-new response)
            (message "Improved text copied to kill ring. Use C-y to paste.")))))))

(defun my/gptel-summarize ()
  "Summarize selected text or buffer."
  (interactive)
  (let ((text (if (region-active-p)
                  (buffer-substring-no-properties (region-beginning) (region-end))
                (buffer-substring-no-properties (point-min) (point-max)))))
    (gptel-request
        (format "Provide a concise summary of:\n\n%s" text)
      :callback
      (lambda (response _info)
        (when response
          (message "Summary: %s" response))))))

(defun my/gptel-switch-to-claude ()
  "Switch to Claude backend."
  (interactive)
  (setq gptel-backend (gptel-get-backend "Claude"))
  (setq gptel-model "claude-sonnet-4-20250514")
  (message "Switched to Claude Sonnet 4"))

(defun my/gptel-switch-to-gpt ()
  "Switch to GPT-4 backend."
  (interactive)
  (setq gptel-backend (gptel-get-backend "ChatGPT"))
  (setq gptel-model "gpt-4o")
  (message "Switched to GPT-4"))

(global-set-key (kbd "C-c SPC 1") #'my/gptel-switch-to-claude)
(global-set-key (kbd "C-c SPC 2") #'my/gptel-switch-to-gpt)
(global-set-key (kbd "C-c SPC q") #'my/gptel-quick-query)
(global-set-key (kbd "C-c SPC e") #'my/gptel-explain-code)
(global-set-key (kbd "C-c SPC i") #'my/gptel-improve-writing)
(global-set-key (kbd "C-c SPC S") #'my/gptel-summarize)

(provide 'lf-ai)
;;; lf-ai.el ends here
