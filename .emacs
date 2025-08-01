;; PACKAGE MANAGEMENT
;;

;; mostly from https://www.shaneikennedy.xyz/blog/emacs-intro 
(require 'package)

;; Nice macro for updating lists in place.
(defmacro append-to-list (target suffix) 
  "Append SUFFIX to TARGET in place."
  `(setq ,target (append ,target ,suffix)))

;; Set up emacs package archives with 'package
(append-to-list package-archives
                '(("melpa" . "http://melpa.org/packages/") ;; Main package archive
                  ("melpa-stable" . "http://stable.melpa.org/packages/") ;; Some packages might only do stable releases?
                  ("org-elpa" . "https://orgmode.org/elpa/"))) ;; Org packages, I don't use org but seems like a harmless default

;; local packages
;; git clone https://github.com/cashpw/repeat-todo.git
;; (add-to-list 'load-path "/Users/c8q9k8/Documents/emacs/local-packages/repeat-todo/")

(package-initialize)
;; refresh the package archive on load so we can pull the latest packages.
(unless (package-installed-p 'use-package) 
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq
 use-package-always-ensure t ;; Makes sure to download new packages if they aren't already downloaded
 use-package-verbose t) ;; Package install logging. Packages break, it's nice to know why.
;; added by Custom, don't edit by hand, don't duplicate
;; (custom-set-variables
;; '(package-selected-packages '(exec-path-from-shell solarized-theme)))
(custom-set-faces )
;; Any Customize-based settings should live in custom.el, not here.
(setq custom-file "~/.emacs.d/custom.el") ;; Without this emacs will dump generated custom settings in this file
(load custom-file 'noerror)


;;
;; BACKUPS & AUTOSAVES
;;
(setq backup-directory-alist `(("." . ,(expand-file-name "tmp/backups/" user-emacs-directory))))

;; auto-save-mode doesn't create the path automatically!
(make-directory (expand-file-name "tmp/auto-saves/" user-emacs-directory) t)

(setq auto-save-list-file-prefix (expand-file-name "tmp/auto-saves/sessions/" user-emacs-directory)
      auto-save-file-name-transforms `((".*" ,(expand-file-name "tmp/auto-saves/" user-emacs-directory) t)))

;; projectile, lsp
(setq projectile-known-projects-file (expand-file-name "tmp/projectile-bookmarks.eld" user-emacs-directory)
      lsp-session-file (expand-file-name "tmp/.lsp-session-v1" user-emacs-directory))

;;
;; THEMING and VISUAL TWEAKS :^)
;;
(use-package solarized-theme
  :init
  (load-theme 'solarized-selenized-dark t))
;; Change the size of markdown-mode headlines (off by default)
(setq solarized-scale-markdown-headlines t)

;; no toolbar
(tool-bar-mode -1)
(menu-bar-mode -1)

;; font !!
;; helpful info:
;; https://jjasghar.github.io/blog/2017/01/04/changing-fonts-in-emacs/

(add-to-list 'default-frame-alist
             '(font . "Victor Mono Medium-16"))
(set-face-attribute 'font-lock-comment-face nil
		    :font "Victor Mono Light Italic 16")
(set-face-foreground 'font-lock-comment-face "floral white")
(set-face-foreground 'font-lock-string-face "medium aquamarine")
(set-face-foreground 'font-lock-builtin-face "LightPink2")
;; padding
(use-package spacious-padding)
(setq spacious-padding-widths
      '( :internal-border-width 15        
	 :header-line-width 4        
	 :mode-line-width 6        
	 :tab-width 4        
	 :right-divider-width 10        
	 :scroll-bar-width 4        
	 :fringe-width 0))
;; Read the doc string of `spacious-padding-subtle-mode-line' as it
;; is very flexible and provides several examples.
(setq spacious-padding-subtle-mode-line     
      `( :mode-line-active 'default       
	 :mode-line-inactive vertical-border))
(spacious-padding-mode 1)
;; Set a key binding if you need to toggle spacious padding.
(define-key global-map (kbd "<f8>") #'spacious-padding-mode)

;; line numbers
(global-display-line-numbers-mode 1)
;; wrap lines when overflow
(setq truncate-lines nil)
(setq truncate-partial-width-windows nil)
;; (setq wrap-prefix "")			
;;
;; WINDOW/FRAME MANAGEMENT
;;
;;; OS specific config
(defconst *is-a-linux* (eq system-type 'gnu/linux))
(when *is-a-linux*
  (setq x-super-keysym 'meta))
;; Fullscreen by default, as early as possible. This tiny window is not enough

(use-package windmove 
  :ensure nil 
  :bind* 
  (("M-<left>" . windmove-left)  
   ("M-<right>" . windmove-right)  
   ("M-<up>" . windmove-up)  
   ("M-<down>" . windmove-down)))

(add-to-list 'default-frame-alist '(fullscreen . maximized))

;;
;; MINIBUFFER and SEARCHING
;;
;; Make M-x and other mini-buffers sortable, filterable
;; better search ergonomics
(keymap-global-set "C-s" 'swiper)
(use-package ivy 
  :init 
  (ivy-mode 1) 
  (setq ivy-height 15       
	ivy-use-virtual-buffers t       
	ivy-use-selectable-prompt t))

(use-package counsel 
  :after ivy
  :init 
  (counsel-mode 1) 
  :bind (:map ivy-minibuffer-map))

(use-package which-key 
  :config (which-key-mode t))

;;
;; DIRED
;;
;; Revert buffers when the underlying file has changed
(global-auto-revert-mode 1)
;; Revert Dired and other buffers
(setq global-auto-revert-non-file-buffers t)
;; PROJECTILE and PROJECT MANAGEMENT
;; We need something to manage the various projects we work on
;; and for common functionality like project-wide searching, fuzzy file finding etc.
(use-package projectile
  :init
  (projectile-mode t) ;; Enable this immediately 
  (setq projectile-project-search-path '("~/Documents/emacs" ("~/Documents/projects/code/*" . 5)))
  :config 
  (define-key projectile-mode-map (kbd "C-c C-p") 'projectile-command-map)
  (global-set-key (kbd "C-c p") 'projectile-command-map)
  (setq projectile-enable-caching t ;; Much better performance on large projects       
	projectile-completion-system 'ivy)) ;; Ideally the minibuffer should aways look similar
;; Counsel and projectile should work together.
(use-package counsel-projectile :init (counsel-projectile-mode))
;; finding stuff more easily
(recentf-mode 1)
(setq history-length 250)
(savehist-mode 1)
;; Company is the best Emacs completion system.
(use-package company
  :bind (("C-." . company-complete)) 
  :custom 
  (company-idle-delay 0) ;; I always want completion, give it to me asap 
  (company-dabbrev-downcase nil "Don't downcase returned candidates.") 
  (company-show-numbers t "Numbers are helpful.") 
  (company-tooltip-limit 10 "The more the merrier.") 
  :config 
  (global-company-mode) ;; We want completion everywhere

  ;; use numbers 0-9 to select company completion candidates 
  (let ((map company-active-map))   
    (mapc (lambda (x) (define-key map (format "%d" x)
				  `(lambda () (interactive) (company-complete-number ,x))))         
          (number-sequence 0 9))))


;;
;; LSP and LANGUAGE SERVERS
;;
;; Flycheck is the newer version of flymake and is needed to make lsp-mode not freak out.
(use-package flycheck
  :config
  (add-hook 'prog-mode-hook 'flycheck-mode) ;; always lint my code 
  (add-hook 'after-init-hook #'global-flycheck-mode))

(use-package lsp-ivy
  :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs
  :commands lsp-treemacs-errors-list)


;; Package for interacting with language servers
(use-package lsp-mode
  :ensure t
  :init
  (setq lsp-keymap-prefix "C-c C-l"
        lsp-inlay-hint-enable t)
  :custom
  (lsp-lens-enable nil)
  (lsp-headerline-breadcrumb-enable nil)
  (lsp-rust-analyzer-cargo-watch-command "clippy")
  ;; enable / disable the hints as you prefer:
  (lsp-inlay-hint-enable t)
  ;; These are optional configurations. See https://emacs-lsp.github.io/lsp-mode/page/lsp-rust-analyzer/#lsp-rust-analyzer-display-chaining-hints for a full list
  (lsp-rust-analyzer-display-lifetime-elision-hints-enable "skip_trivial")
  (lsp-rust-analyzer-display-chaining-hints t)
  (lsp-rust-analyzer-display-lifetime-elision-hints-use-parameter-names nil)
  (lsp-rust-analyzer-display-closure-return-type-hints t)
  (lsp-rust-analyzer-display-parameter-hints nil)
  (lsp-rust-analyzer-display-reborrow-hints nil)
  (lsp-signature-auto-activate t)
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
	 (python-mode . lsp)
	 (rust-mode . lsp)
	 (lisp-mode . lsp)
	 (typescript-mode . lsp)
	 (rsjx-mode . lsp)        ;; if you want which-key integration
	 (lsp-mode . lsp-enable-which-key-integration))
  (rustic-mode . lsp)
  ;; if you want which-key integration
  (lsp-mode . lsp-ui-mode)
  :commands lsp
  :config (setq lsp-prefer-flymake nil ;; Flymake is outdated
		lsp-headerline-breadcrumb-mode nil)) ;; I don't like the symbols on the header a-la-vscode, remove this if you like them.

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :after lsp-mode
  :custom
  (lsp-ui-peek-always-show nil)
  (lsp-ui-sideline-show-hover nil)
  (lsp-ui-doc-enable t)
  )

;; language servers and development
(use-package npm)
(use-package tree-sitter)
(use-package tree-sitter-langs)
(use-package typescript-mode)
(setq treesit-language-source-alist  
      '((bash https://github.com/tree-sitter/tree-sitter-bash)    
	(cmake https://github.com/uyha/tree-sitter-cmake)   
	(css https://github.com/tree-sitter/tree-sitter-css)   
	(elisp https://github.com/Wilfred/tree-sitter-elisp)    
	(go https://github.com/tree-sitter/tree-sitter-go)    
	(html https://github.com/tree-sitter/tree-sitter-html)    
	(javascript https://github.com/tree-sitter/tree-sitter-javascript "master" "src")    
	(json https://github.com/tree-sitter/tree-sitter-json)    
	(make https://github.com/alemuller/tree-sitter-make)    
	(markdown https://github.com/ikatyang/tree-sitter-markdown)    
	(python https://github.com/tree-sitter/tree-sitter-python)    
	(toml https://github.com/tree-sitter/tree-sitter-toml)    
	(tsx https://github.com/tree-sitter/tree-sitter-typescript "master" "tsx/src")    
	(typescript https://github.com/tree-sitter/tree-sitter-typescript "master" "typescript/src")   
	(yaml https://github.com/ikatyang/tree-sitter-yaml)    
	(rust https://github.com/tree-sitter/tree-sitter-rust)))

;; python specific
;; see
;; https://slinkp.com/python-emacs-lsp-20231229.html
;; once u get direnv working:
;;(use-package envrc
;;  :hook (after-init . envrc-global-mode))
(use-package rustic
  :ensure
  :bind (:map rustic-mode-map
              ("M-j" . lsp-ui-imenu)
              ("M-?" . lsp-find-references)
              ("C-c C-c l" . flycheck-list-errors)
              ("C-c C-c a" . lsp-execute-code-action)
              ("C-c C-c r" . lsp-rename)
              ("C-c C-c q" . lsp-workspace-restart)
              ("C-c C-c Q" . lsp-workspace-shutdown)
              ("C-c C-c s" . lsp-rust-analyzer-status)))
:config
;; uncomment for less flashiness
;; (setq lsp-eldoc-hook nil)
;; (setq lsp-enable-symbol-highlighting nil)
;; (setq lsp-signature-auto-activate nil)

;; comment to disable rustfmt on save
(setq rustic-format-on-save t)


;;
;; MARKDOWN
;;
;; markdown mode
(use-package markdown-mode
  :ensure t
  :mode
  ("README\\.md\\'" . gfm-mode)
  :init
  (setq markdown-command "multimarkdown")
  :bind
  (:map markdown-mode-map
	("C-c C-e" . markdown-do)))

;;
;; VERSION CONTROL 
;;
(use-package magit)
(use-package diff-hl)
(global-diff-hl-mode)

;; remote machines and local servers

;;
;;
;; ORG MODE
;;
(require 'org)
;; keybindings
(keymap-global-set "C-c l" 'org-store-link)
(keymap-global-set "C-c a" 'org-agenda)
(keymap-global-set "C-c c" 'org-capture)

;; below are defaults, here for reference
(keymap-global-set "C-c C-d" 'org-deadline)
(keymap-global-set "C-c C-s" 'org-schedule)

;; org dir
(setq org-directory "~/emacs/org/")
;; org agenda
(setq org-agenda-files '("~/emacs/org/" "~/emacs/org/SHARED/"))
;; Associate all org files with org mode
(add-to-list 'auto-mode-alist '(".org" . org-mode))
;; Follow the links
(setq org-return-follows-link  t)
;; Make the indentation look nicer
(add-hook 'org-mode-hook 'org-indent-mode)
;; capture templates
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline "~/emacs/org/SHARED/todos.org" "Captured")
      	 "** TODO %?\n  %i\n  %a")
       ("j" "Jobs" entry (file+datetree "~/emacs/org/jobs.org")
	 "* Job - %?\n  %U\n  %i\n")
	("d" "Diary" entry (file+datetree "~/emacs/org/diary.org")
	 "* %?\nEntry  %U\n  %i\n  %a")))
 
;; refiling
(setq org-refile-targets     '((nil :maxlevel . 2)))
;; archiving
(setq org-archive-location "%s_archive::datetree/* Archived")

;; styles
;; Hide the markers so you just see bold text as BOLD-TEXT and not *BOLD-TEXT*
(setq org-hide-emphasis-markers t)
;; and the stars for headings
(setq org-hide-leading-stars t)
;; and make indented text
(setq org-startup-indented t)
;; make TODAY red
(setq org-todo-keyword-faces
      '(
	("TODAY" . (:foreground "IndianRed" :weight bold))))
;; don't fucking truncate my lines
(setq org-startup-truncated nil)
;; show future days
(setq org-habit-show-habits-only-for-today nil)

;; create log file
(setq org-log-into-drawer "LOGBOOK")
(add-to-list 'org-modules 'org-habit t)
;; each state with ! is recorded as state change
;; logging TODO and DONE states
(setq org-todo-keywords    
      '((sequence "TODO(t!)" "TODAY(a)" "PROGRESS(p)" "BLOCKED(b)" "|" "DONE(d!)" "CANC(c!)")))
;; log TODO creation also
(setq org-treat-insert-todo-heading-as-state-change t)
;; log into LOGBOOK drawer
(setq org-log-into-drawer t)
;; don't allow parents to be DONE until children are DONE
(setq org-enforce-todo-dependencies t)
;; habits which repeat on specific days
;; (use-package repeat-todo
;;  :after org)

;;
;; TWEAKS and FUNCTIONS
;;

;; Slurp environment variables from the shell.
;; a.k.a. The Most Asked Question On r/emacs
;; reenable me if needed, i take like 3 seconds to boot up each time
;; (use-package exec-path-from-shell :config (exec-path-from-shell-initialize))

;; copying file names
(defun copy-file-name-to-clipboard ()
  "Copy the current buffer file name to the clipboard."
  (interactive)
  (let ((filename (if (equal major-mode 'dired-mode)
		      default-directory
		    (buffer-file-name))))
    (when filename
      (kill-new filename)
      (message "Copied buffer file name '%s' to the clipboard." filename))))

;; smooth scroll for images
;; (setq pixel-scroll-precision-mode )

;; i don't know why we need this
(provide '.emacs)
;;; .emacs ends here

