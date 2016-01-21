;;; coverage-mode.el --- Code coverage line highlighting for Emacs

;; Copyright (C) 2016 Powershop NZ Ltd.

;; Author: Kieran Trezona-le Comte
;; URL: https://github.com/trezona-lecomte/coverage-mode
;; Version: 0.1
;; Created: 2016-01-21
;; Keywords: coverage, metric
;; Package-Requires: ((ov "1.0"))

;; This file is NOT part of GNU Emacs.

;;; License:

;; Permission is hereby granted, free of charge, to any person obtaining
;; a copy of this software and associated documentation files (the
;; "Software"), to deal in the Software without restriction, including
;; without limitation the rights to use, copy, modify, merge, publish,
;; distribute, sublicense, and/or sell copies of the Software, and to
;; permit persons to whom the Software is furnished to do so, subject to
;; the following conditions:

;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
;; LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
;; OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
;; WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

;;; Commentary:

(load-library "ov")
(require 'json)

;;; Code:

(defgroup coverage-mode nil
  "Code coverage line highlighting for Emacs.")

(defvar resultset-filepath "/Users/kieran/dev/guildhall/coverage/.resultset.json")

;;; Faces

(defface covered-face
  '((((class color) (background light))
     :background "#ddffdd")
    (((class color) (background dark))
     :background "#335533"))
  "Face for covered lines of code."
  :group 'coverage-mode)

(defface uncovered-face
  '((((class color) (background light))
     :background "#ffdddd")
    (((class color) (background dark))
     :background "#553333"))
  "Face for uncovered lines of code."
  :group 'coverage-mode)

(defvar covered-face 'covered-face)
(defvar uncovered-face 'uncovered-face)

(defun clear-coverage-highlighting-for-current-buffer ()
  "Clear all coverage highlighting for the current buffer."
  (ov-clear))

(defun draw-coverage-highlighting-for-current-buffer ()
  "Highlight the lines of the current buffer, based on code coverage."
  (save-excursion
    (goto-char (point-min))
    (dolist (element (get-coverage-for-current-buffer))
      (cond ((eq element nil)
             (ov-clear (line-beginning-position) (line-end-position)))
            ((= element 0)
             (ov (line-beginning-position) (line-end-position) 'face 'uncovered-face))
            ((> element 0)
             (ov (line-beginning-position) (line-end-position) 'face 'covered-face)))
      (forward-line))))

(defun get-coverage-for-current-buffer ()
  "Return a list of coverage for the current buffer."
  (get-coverage-for-file buffer-file-name resultset-filepath))

(defun get-coverage-for-file (target-path result-path)
  "Return coverage for the file at TARGET-PATH from resultset at RESULT-PATH."
  (coerce (cdr
           (assoc-string target-path
                         (assoc 'coverage
                                (assoc 'RSpec
                                       (get-results-from-json result-path)))))
          'list))

(defun get-results-from-json (filepath)
  "Return alist of the json resultset at FILEPATH."
  (json-read-from-string (with-temp-buffer
                           (insert-file-contents filepath)
                           (buffer-string))))

(define-minor-mode coverage-mode
  "Coverage mode"
  nil nil nil
  (if coverage-mode
      (progn
        (draw-coverage-highlighting-for-current-buffer))
    (clear-coverage-highlighting-for-current-buffer)))

(provide 'coverage-mode)

;;; coverage-mode.el ends here
