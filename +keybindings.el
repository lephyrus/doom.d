;; cursor movement
(map! :map general-override-mode-map
      "M-j" 'backward-char
      "M-l" 'forward-char
      "M-i" 'previous-line
      "M-k" 'next-line
      "M-u" 'backward-word
      "M-o" 'forward-word
      "M-U" 'backward-paragraph
      "M-O" 'forward-paragraph
      "M-J" 'beginning-of-line
      "M-L" 'end-of-line
      "M-I" 'scroll-down
      "M-K" 'scroll-up
      "M-C-j" 'backward-sexp
      "M-C-l" 'forward-sexp
      "M-h" 'beginning-of-buffer
      "M-H" 'end-of-buffer)

;; window navigation
(map! :map general-override-mode-map
      "C-d" 'windmove-right
      "C-w" 'windmove-up
      "C-s" 'windmove-down
      "C-a" 'windmove-left)

;; window organisation
(map! :map general-override-mode-map
      "M-0" 'delete-window
      "M-1" 'zoom-window-zoom
      "M-2" 'split-window-vertically
      "M-3" 'split-window-horizontally
      "M-4" 'balance-windows)

;; M-x
(map! :map general-override-mode-map
     "M-x" nil
     "M-a" 'execute-extended-command)

;; open file, starting at current directory
(map!
  "C-o" 'find-file)

;; workspaces
(map!
 "C-M-," '+workspace/switch-left
 "C-M-." '+workspace/switch-right)

;; projects
(map! :map projectile-mode-map
      "C-p" projectile-command-map)

;; mark
(map!
 "M-SPC" 'set-mark-command)

;; kill ring
(map!
 "M-z" 'undo
 "M-Z" 'redo
 "M-x" 'kill-region
 "M-c" 'kill-ring-save
 "M-v" 'yank
 "C-M-v" 'yank-pop
 "C-k" 'kill-line)

(map! :map global-map
 "C-f" '+default/search-buffer)

;; magit
(map! :map magit-mode-map
      "C-1" 'magit-section-show-level-1-all
      "C-2" 'magit-section-show-level-2-all
      "C-3" 'magit-section-show-level-3-all
      "C-4" 'magit-section-show-level-4-all)

;; copilot
(map! :map company-active-map
     "C-<tab>" nil)
(map! :map copilot-completion-map
      "C-<tab>" 'copilot-accept-completion)

;; misc
(map!
 "C-;" 'comment-line
 "C-SPC" 'company-complete
 "M-RET" '+default/newline-below)
