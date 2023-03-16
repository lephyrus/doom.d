;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; Show buffer type icons in modeline
(setq doom-modeline-major-mode-icon t)

;; Always use tab width of 2
(setq-default tab-width 2)

;; Theme
(setq doom-theme 'doom-nord)
(after! doom-themes
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (doom-themes-visual-bell-config))

;; Font
;; (setq doom-font (font-spec :family "Inconsolata" :size 14))

;; Better projectile config for NPM projects
(after! projectile
  (projectile-update-project-type 'npm
                                  :compile "yarn install"
                                  :test "yarn test"
                                  :run "yarn start"
                                  :test-suffix ".spec"))

;; Use git respositories as known projects
(after! magit
  (setq magit-repository-directories
        '(;; Directory containing project root directories
          ("~/Code/"    . 2)
          ;; Specific project root directory
          )))
(after! (projectile magit)
  (mapc #'projectile-add-known-project
        (mapcar #'file-name-as-directory (magit-list-repos)))
  (projectile-add-known-project "~/.doom.d/")
  (projectile-add-known-project "~/.config/")
  ;; Optionally write to persistent `projectile-known-projects-file'
  (projectile-save-known-projects))


;; Undo only in selected region
(after! undo-fu
  (setq undo-fu-allow-undo-in-region t))

;; Default to prettier formatting for html files
(setq-hook! 'web-mode-hook +format-with 'prettier-js)
;; Format with Prettier on save
(add-hook! (typescript-mode web-mode js2-mode json-mode) 'prettier-js-mode)

;; Different modeline color for zoomed windows (doesn't always work?)
(use-package! zoom-window
  :config (setq zoom-window-mode-line-color "DarkOrchid"))

;; use running emacs as editor from vterm
(add-hook 'vterm-mode-hook 'with-editor-export-editor)

;; accept completion from copilot and fallback to company
(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :config (setq copilot-idle-delay 1))
;; :bind (("C-TAB" . 'copilot-accept-completion-by-word)
;;        ("C-<tab>" . 'copilot-accept-completion-by-word)
;;        :map copilot-completion-map
;;        ("<tab>" . 'copilot-accept-completion)
;;        ("TAB" . 'copilot-accept-completion)))

;; No snippet completion
(setq +lsp-company-backends '(company-capf))

;; lsp
(after! lsp
  (push "[/\\\\]docker\\'" lsp-file-watch-ignored-directories)
  (push "[/\\\\]coverage\\'" lsp-file-watch-ignored-directories)
  (push "[/\\\\].angular\\'" lsp-file-watch-ignored-directories))
;; disable snippet completion
(after! lsp-mode
  (setq lsp-enable-snippet nil)
  (setq lsp-modeline-code-actions-enable nil)
  (setq lsp-modeline-diagnostics-enable nil))
(after! lsp-ui-sideline
  (setq lsp-ui-sideline-diagnostic-max-lines 5))
;; (after! lsp-ui-doc
;;   (setq lsp-ui-doc-use-childframe nil)
;;   (setq lsp-ui-doc-show-with-cursor t))
(after! (:and warnings lsp-mode)
  (add-to-list 'warning-suppress-types '(lsp-mode)))

;; Keybindings
(load! "+keybindings.el")

;; fix for lsp-rename failing if ts-ls and angular-ls want to edit the same file
(defun my/rename ()
  (interactive)
  (if-let ((wks (lsp-find-workspace 'angular-ls)))
      (with-lsp-workspace wks
        (call-interactively 'lsp-rename))
    (call-interactively 'lsp-rename)))

(defun doom/ediff-init-and-example ()
  "ediff the current `init.el' with the example in doom-emacs-dir"
  (interactive)
  (ediff-files (concat doom-user-dir "init.el")
               (concat doom-emacs-dir "templates/init.example.el")))

(define-key! help-map
  "di"   #'doom/ediff-init-and-example)

;; autosave recently used files (better session restore after unclean shutdown)
(after! recentf
  (recentf-load-list)
  (run-at-time nil (* 60 60) #'recentf-save-list)) ; every 60 mins
