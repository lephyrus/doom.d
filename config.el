;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
;; Line numbers are pretty slow all around. The performance boost of disabling
;; them outweighs the utility of always keeping them on.
(setq display-line-numbers-type nil)

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
          )
        magit-list-refs-sortby "-committerdate"
        transient-values '((magit-rebase "--autosquash" "--autostash")
                           (magit-pull "--rebase" "--autostash")
                           (magit-revert "--autostash")
                           (magit-diff:magit-diff-mode "--color-moved=dimmed-zebra" "--color-moved-ws=ignore-all-space" "--no-ext-diff" "--stat"))))

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

;; Different modeline color for zoomed windows (doesn't always work?)
(use-package! zoom-window
  :config (setq zoom-window-mode-line-color "DarkOrchid"))

;; use running emacs as editor from vterm
(add-hook 'vterm-mode-hook 'with-editor-export-editor)

;; enable copilot, with delay
(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :config (setq copilot-idle-delay 1))

;; lsp
(after! lsp
  (push "[/\\\\]docker\\'" lsp-file-watch-ignored-directories)
  (push "[/\\\\]coverage\\'" lsp-file-watch-ignored-directories)
  (push "[/\\\\].angular\\'" lsp-file-watch-ignored-directories))
;; as per FAQ: avoid eslint (and other multiroot servers) always starting in all
;; workspace folders that were ever added
(advice-add 'lsp :before (lambda (&rest _args) (eval '(setf (lsp-session-server-id->folders (lsp-session)) (ht)))))

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

(defun my-vterm/split-right ()
  "Create a new vterm window to the right of the current one."
  (interactive)
  (let* ((ignore-window-parameters t)
         (dedicated-p (window-dedicated-p)))
    (split-window-horizontally)
    (other-window 1)
    (+vterm/here default-directory)))

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

;; lsp support for tailwind
(after! lsp-tailwindcss
  (setq lsp-tailwindcss-add-on-mode t))

;; jest minor mode
(add-hook! '+javascript-npm-mode-hook 'jest-minor-mode)

;; make compile-goto-error work in jest output
(push 'jest-error compilation-error-regexp-alist)
(push '(jest-error
        "^[ ]*at .* (\\([^:]+\\):\\([0-9]+\\):\\([0-9]+\\))" 1 2)

      compilation-error-regexp-alist-alist)

(use-package! gleam-ts-mode)
;; enable gleam-ts-mode for .gleam files
(add-to-list 'auto-mode-alist '("\\.gleam\\'" . gleam-ts-mode))
