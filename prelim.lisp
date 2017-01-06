; -*- mode:     CL -*- ----------------------------------------------------- ;
; File:         COMPILE-ZEBU.lisp
; Description:  compiling Zebu without DEFSYS
; Author:       Joachim H. Laubsch
; Created:      13-May-92
; Modified:     Thu Mar  7 13:13:40 1996 (Joachim H. Laubsch)
; Language:     CL
; Package:      CL-USER
; Status:       Experimental (Do Not Distribute)
; RCS $Header: $
;
; (c) Copyright 1992, Hewlett-Packard Company
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Revisions:
; RCS $Log: $
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#+MCL
(unless (find-package "CL-USER")
  (defpackage "USER" (:nicknames "COMMON-LISP-USER" "CL-USER")))

(in-package :zb)

(push 'CLISP *features*)

#-LUCID
(declaim (special *ZEBU-directory* *ZEBU-binary-directory*))
#+LUCID
(proclaim '(special *ZEBU-directory* *ZEBU-binary-directory*))

;; edit the following form for your Lisp, and the directory where you keep Zebu
(eval-when (:execute :load-toplevel :compile-toplevel)
  (defparameter *ZEBU-directory*
    (make-pathname
     :directory
     (pathname-directory
      #+CLISP   *load-truename*
      #-ALLEGRO #+MCL (truename *loading-file-source-file*)
    ;;;#-ALLEGRO #-MCL *load-pathname*
      #+sbcl *default-pathname-defaults*
      #+ALLEGRO (merge-pathnames *load-pathname*
				 *default-pathname-defaults*)))
    ))

(defparameter *ZEBU-binary-directory*
  (make-pathname :directory (append (pathname-directory *ZEBU-directory*)
				    (list "binary"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; compilation: Production mode
#+LUCID(proclaim '(optimize (speed 3) (safety 0) (compilation-speed 0)))
#-LUCID(declaim (optimize (speed 3) (safety 0) (compilation-speed 0)))

;; compilation: Test mode
;;(proclaim '(optimize (speed 0) (safety 3)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#+LUCID(or (probe-file *ZEBU-binary-directory*)
	   (shell (format nil "mkdir ~a" (namestring *ZEBU-binary-directory*))))

#+ALLEGRO(unless (probe-file *ZEBU-binary-directory*)
	   (let ((dir (format nil "~abinary"
			      (namestring *ZEBU-directory*))))
	     (unless (zerop (run-shell-command
			     (format nil "mkdir ~a" dir)))
	       (error "Could not create directory ~s" dir))))

#+MCL(create-file *ZEBU-binary-directory* :if-exists nil)
#+(and WINDOWS ACL3.0)
(create-directory *ZEBU-binary-directory*)

;; #+(or MCL Allegro CLISP)
;; (declaim (special *load-source-pathname-types* *load-binary-pathname-types*))

(defparameter *load-source-pathname-types* '("lisp" NIL))

(defparameter *load-binary-pathname-types* '("fasl"))


(in-package :zebu)
(defvar *NULL-Grammar*)
(defvar *zebu-version*)

(defvar *generate-domain* t
  "if true while zebu compiling a grammar, generate the hierarchy
otherwise the domain-hierarchy is written by the user.")

(defvar *warn-conflicts* nil)

(defun zebu-compile-file (grammar-file
			  &key (grammar *null-grammar*)
			  output-file
			  verbose
			  (compile-domain t))
  "compiles the lalr(1) grammar in file grammar-file."
  (assert (probe-file (setq grammar-file
                        (merge-pathnames grammar-file
                                         (merge-pathnames
					  (make-pathname :type "zb")))))
	  (grammar-file)
	  "cannot find grammar file: ~a" grammar-file)
  (setq output-file
	(let ((tab (make-pathname :type "tab")))
          (if output-file
	      (merge-pathnames (pathname output-file) tab)
            (merge-pathnames tab grammar-file))))
  (when (probe-file output-file) (delete-file output-file))
  (format t "~%; zebu compiling (version ~a)~%; ~s to ~s~%"
	  *zebu-version* grammar-file output-file)
  (let ((*warn-conflicts* verbose))
    (compile-lalr1-grammar grammar-file
			   :output-file output-file
			   :grammar grammar
			   :verbose verbose
			   :compile-domain compile-domain)))


(defun do-post-poned-load ()
  (dolist (file-path (nreverse load-before-compile))
    (load (merge-pathnames file-path binary-path)))
  (setq load-before-compile nil))
