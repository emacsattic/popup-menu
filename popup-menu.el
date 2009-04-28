;;;   popup-menu.el  -- pop up a menu under the mouse pointer
;;;   $Id: popup-menu.el,v 1.6 1999/10/18 17:52:53 kiesling Exp $
;;;
;;;   This file is not part of GNU Emacs, but is copyrighted by
;;;   the GNU General Public License, http://www.gnu.org/
;;;
;;;   Displays a pop-up menu under a mouse event.
;;;
;;;   This is an abbreviated version of the previous revision, since
;;;   all it does is pop up whatever would have appeared in the menu
;;;   bar; per RMS's request.
;;;
;;;   The require and provides statements were added at the suggestion
;;;   of gaz@gwoven.freeserve.ac.uk, to bring the code in line with
;;;   the standard Emacs Lisp package loading.
;;;
;;;   To use popup-menu.el, tell Emacs to load it on startup.
;;;   For example, my .emacs contains the following:
;;;
;;;   (require 'popup-menu)
;;;
;;;   The choice of colors can make the menus much easier to read.  
;;;   The definitions of my ~/.Xresources file are:
;;;
;;;   Emacs.menu*.font: -*-lucidatypewriter-medium-*-*-*-12-120-*-*-*-*-*-*
;;;   Emacs.menu*.foreground: Black
;;;   Emacs.menu*.background: LightGray
;;;   Emacs.menu*.buttonForeground: Black
;;;
;;;   The complete list of resources is given in the Emacs Texinfo manual.
;;;
;;;   You need to use a monospaced font only if you care about the key
;;;   definitions being nicely aligned on the screen.
;;;

(defvar popup-menu-keymap nil
"Local keymap when popup-menu-mode is enabled."
)

(if (not popup-menu-keymap)
    (progn
      (setq popup-menu-keymap (make-sparse-keymap))
      (define-key popup-menu-keymap [down-mouse-3] 'popup-menu)))

(defvar popup-menu-mode nil)

(defun popup-menu-mode (flag)
 "Minor mode.  With no argument, toggle popup-menu-mode.  
Argument, if present and positive, sets popup-menu-mode.  
If argnument is 0 or negative, clear popup-menu-mode.

\\{popup-menu-keymap}"

  (interactive "P")

  (setq popup-menu-mode
        (if (null flag) (not popup-menu-mode)
            (> (prefix-numeric-value flag) 0)))

  (if popup-menu-mode
      (mapcar '(lambda (buf)
                 (save-current-buffer
                   (set-buffer buf)
                   (or (assq 'popup-menu-mode minor-mode-alist )
                       (setq minor-mode-alist
                             (cons '(popup-menu-mode nil) minor-mode-alist))
                       )
                   (or (assq 'popup-menu-mode minor-mode-map-alist )
                             (setq minor-mode-map-alist
                                         (cons (cons 'popup-menu-mode
                                                     popup-menu-keymap)
                                               minor-mode-map-alist)))))
                (funcall 'buffer-list))

      (mapcar '(lambda (buf)
                 (save-current-buffer
                   (set-buffer buf)
                   (and (assq 'popup-menu-mode minor-mode-alist )
                       (setq minor-mode-alist
                             (delete '(popup-menu-mode nil) minor-mode-alist)))
                   (and (assq 'popup-menu-mode minor-mode-map-alist)
                        (setq minor-mode-map-alist
                              (delete (cons 'popup-menu-mode popup-menu-keymap)
                                      minor-mode-map-alist)))))
        (funcall 'buffer-list)))

)

(defvar result nil)

(defun popup-menu (event prefix)
  "Pops up the menu bar con
tents under a keyboard event. The code is adapted from the code in mouse.el."
  (interactive "@e \nP")
  (setq result nil)

  (setq local-popup-map
        ( if (current-local-map)
            (lookup-key (current-local-map) [menu-bar])))
  (if local-popup-map
      (setq popup-map-list (list (lookup-key global-map [menu-bar])
                            local-popup-map))
    (setq popup-map-list (lookup-key global-map [menu-bar])))

  (setq result (x-popup-menu last-nonmenu-event popup-map-list))

   (if result
             (let ((command (key-binding
                             (apply 'vector (append '(menu-bar)
                                                    prefix
                                                    result)))))
               (if command
                   (progn
                     (setq prefix-arg prefix)
                     (command-execute command))))))

(provide 'popup-menu)

;;; popup-menu.el ends here.
