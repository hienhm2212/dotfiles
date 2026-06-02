;;; lf-lang-rust.el --- Rust language support -*- lexical-binding: t; -*-
;;; Commentary:
;; rust-mode with eglot/rust-analyzer.
;; Prerequisites: rustup component add rust-analyzer

;;; Code:

(use-package rust-mode
  :ensure t
  :mode "\\.rs\\'")

;; rust-analyzer is auto-configured by eglot for rust-mode and rust-ts-mode.
;; No additional eglot-server-programs entry needed.

(provide 'lf-lang-rust)
;;; lf-lang-rust.el ends here
