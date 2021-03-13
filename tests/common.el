;;; common.el --- Common code to run before each test
(require 'xref)

(defconst default-tags "target.tags"
  "Default tags file under each test case directory.")

(setq citre-readtags-program (getenv "READTAGS"))

(defun expand-test-file (&optional file)
  "Get the absolute path of FILE.
FILE is a relative path against the test case directory.  If it's
nil, the value of `default-tags' is used.

This is for use in the batch mode.  You should start Emacs with
the working directory being a test case directory to ensure this
work correctly."
  (let ((file (or file default-tags)))
    (expand-file-name (concat default-directory file))))

(defun get-*find-definitions* (mode buffer-file
				    marker extra-move
				    &optional tags-file)
  "Get the buffer content created by `xref-find-definitions'.
MODE, BUFFER-FILE, MARKER, and EXTRA-MOVE make a buffer
from where `xref-find-definitions' is called.
MODE is a function for entering a major mode.
BUFFER-FILE is a file name that content fills the buffer.
MARKER, and EXTRA-MOVE are for adjusting the point in the buffer.
MARKER is a pattern string. This function searches MARKER
with `re-search-forward` from the beginning of the buffer.
EXTRA-MOVE is a function taking no argument. After searching
MARKER, EXTRA-MOVE is called.
After adjusting the point in this way, `xref-find-definitions' is
called.
Before returning the buffer content, following modifications
are made:
- dropping string properties, and
- convert absolute paths to relative paths."
  (let ((d (concat "^" (regexp-quote (expand-file-name default-directory)))))
    (with-temp-buffer
      (insert-file buffer-file)
      (funcall mode)
      (add-hook 'xref-backend-functions #'citre-xref-backend nil t)
      (setq-local citre--tags-file (expand-test-file tags-file))
      (goto-char (point-min))
      (re-search-forward marker)
      (when extra-move
	(funcall extra-move))
      (xref--find-definitions
       (xref-backend-identifier-at-point (xref-find-backend))
       nil)
      (replace-regexp-in-string
       d
       ""
       (with-current-buffer "*xref*"
	 (buffer-substring-no-properties
	  (point-min) (point-max)))))))

(defun get-file-contet (file)
  "Get file content of FILE."
  (with-temp-buffer
    (insert-file file)
    (buffer-substring-no-properties
     (point-min) (point-max))))
