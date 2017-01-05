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

(in-package "CL-USER")

#-LUCID
(declaim (special *ZEBU-directory* *ZEBU-binary-directory*))
#+LUCID
(proclaim '(special *ZEBU-directory* *ZEBU-binary-directory*))

;; edit the following form for your Lisp, and the directory where you keep Zebu
(defparameter *ZEBU-directory*
  (make-pathname 
   :directory
   (pathname-directory
    #+CLISP   *load-truename*
    #-ALLEGRO #+MCL (truename *loading-file-source-file*) 
    #-ALLEGRO #-MCL *load-pathname*
    #+ALLEGRO (merge-pathnames *load-pathname*
			       *default-pathname-defaults*)))
  )

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

#+(or MCL Allegro CLISP)
(declaim (special *load-source-pathname-types* *load-binary-pathname-types*))

#+(or MCL Allegro CLISP)
(setq *load-source-pathname-types* '("lisp" NIL))
#+(and WINDOWS ACL3.0)
(defvar *load-source-pathname-types* '("lsp" NIL))

#+(or MCL Allegro)
(setq *load-binary-pathname-types* '("fasl"))
#+(and :SUN :LUCID)
(setq *load-binary-pathname-types* '("sbin"))
#+CLISP
(setq *load-binary-pathname-types* '("fas"))
#+(and WINDOWS ACL3.0)
(defvar *load-binary-pathname-types* '("fsl"))

(let ((*default-pathname-defaults*
       (merge-pathnames
	*ZEBU-directory*
	(make-pathname :type (first *load-source-pathname-types*)))))
  (load (merge-pathnames "zebu-package")))

(let ((source-path (merge-pathnames
		    *ZEBU-directory*
		    (make-pathname
		     :type (first *load-source-pathname-types*))))
      (binary-path (merge-pathnames
		    (make-pathname
		     :type (first *load-binary-pathname-types*))
		    *ZEBU-binary-directory*))
      (*compile-verbose* t)
      (*load-verbose* t)
      (load-before-compile '()))
  (flet ((do-post-poned-load ()
	   (dolist (file-path (nreverse load-before-compile))
	     (load (merge-pathnames file-path binary-path)))
	   (setq load-before-compile nil)))
    (dolist (task '((compile "zebu-package")
		    (compile "zebu-aux")
		    (load    "zebu-aux")
		    (compile "zebu-kb-domain")
		    (load    "zebu-kb-domain")
		    (compile "zebu-mg-hierarchy")
		    (load    "zebu-mg-hierarchy")
		    (compile "zebu-regex")
		    (load    "zebu-regex")
		    (compile "zebu-loader")
		    (load    "zebu-loader")
		    (compile "zebu-driver")
		    (compile "zebu-actions")
		    (compile "zebu-oset")
		    (load    "zebu-oset")
		    (compile "zebu-g-symbol")
		    (load    "zebu-g-symbol")
		    (compile "zebu-loadgram")
		    (load    "zebu-loadgram")
		    (compile "zebu-generator")
		    (load    "zebu-generator")
		    (compile "zebu-lr0-sets")
		    (load    "zebu-lr0-sets")
		    (compile "zebu-empty-st")
		    (load    "zebu-empty-st")
		    (compile "zebu-first")
		    (load    "zebu-first")
		    (compile "zebu-follow")
		    (load    "zebu-follow")
		    (compile "zebu-tables")
		    (compile "zebu-slr")
		    (load    "zebu-slr")
		    (compile "zebu-closure")
		    (load    "zebu-closure")
		    (compile "zebu-lalr1")
		    (load    "zebu-lalr1")
		    (compile "zebu-dump")
		    (load    "zebu-dump")
		    (compile "zebu-compile")
		    (load    "zebu-compile")
		    (load    "zebu-tables")
		    (compile "zebu-printers")
		    (load    "zebu-printers") ; only for debugging
		    (zebu    "zebu-mg")
		    (compile "zmg-dom")
		    (compile "zebu-kb-domain")
		    (load    "zebu-kb-domain")
		    (compile "zebu-tree-attributes")
		    (load    "zebu-tree-attributes")
		    (compile "zebra-debug")))
      (let ((file-path (make-pathname :name (cadr task))))
	;; (print task)
	(case (car task)
	  (compile (let* ((ofile (merge-pathnames file-path binary-path))
			  (odate (and (probe-file ofile)
				      (file-write-date ofile)))
			  (ifile (merge-pathnames file-path source-path))
			  (idate (if (probe-file ifile)
				     (file-write-date ifile)
				   (error "File not found ~a" ifile))))
		     (when (or (null odate) (> idate odate))
		       ;; now do the postponed loads
		       (do-post-poned-load)
		       (compile-file ifile :output-file ofile))))
	  (load				; postpone load
	   (push file-path load-before-compile))
	  (zebu    (let* ((ofile (merge-pathnames
				  (merge-pathnames
				   (make-pathname :type "tab")
				   file-path)
				  binary-path))
			  (odate (and (probe-file ofile)
				      (file-write-date ofile)))
			  (ifile (merge-pathnames
				  (merge-pathnames
				   (make-pathname :type "zb")
				   file-path)
				  source-path))
			  (idate (if (probe-file ifile)
				     (file-write-date ifile)
				   (error "File not found ~a" ifile)))
			  zb:*generate-domain*)
		     (when (or (null odate) (> idate odate))
		       (do-post-poned-load)
		       (ZB:zebu-compile-file ifile :output-file ofile)))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                            End of COMPILE-ZEBU.l
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
