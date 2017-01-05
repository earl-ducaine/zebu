;;; This file was generated by Zebu (Version 3.4.8)

(IN-PACKAGE "ZEBU")
(REQUIRE "zebu-package")
(USE-PACKAGE "ZEBU")


(DEFUN MORE-RHS2
       (DUMMY RHS1 MORE-RHS)
       (DECLARE (IGNORE DUMMY))
       (CONS RHS1 MORE-RHS))

(DEFUN CONSTITUENT5
       (IDENTIFIER DUMMY STRING)
       (DECLARE (IGNORE DUMMY))
       (MAKE-KLEENE* :-CONSTITUENT
                     IDENTIFIER
                     :-SEPARATOR
                     STRING))

(DEFUN CONSTITUENT6
       (IDENTIFIER DUMMY STRING)
       (DECLARE (IGNORE DUMMY))
       (MAKE-KLEENE+ :-CONSTITUENT
                     IDENTIFIER
                     :-SEPARATOR
                     STRING))

(DEFUN RHS17
       (CONSTITUENT-LIST)
       (MAKE-PRODUCTION-RHS :-SYNTAX CONSTITUENT-LIST))

(DEFUN RHS18
       (CONSTITUENT-LIST DUMMY FEAT-TERM DUMMY1)
       (DECLARE (IGNORE DUMMY1 DUMMY))
       (MAKE-PRODUCTION-RHS :-SYNTAX
                            CONSTITUENT-LIST
                            :-SEMANTICS
                            FEAT-TERM))

(DEFUN ZB-RULE9
       (NON-TERMINAL DUMMY RHS DUMMY1)
       (DECLARE (IGNORE DUMMY1 DUMMY))
       (MAKE-ZB-RULE :-NAME NON-TERMINAL :-PRODUCTIONS RHS))

(DEFUN LABEL-VALUE-PAIR10
       (DUMMY IDENTIFIER FEAT-TERM DUMMY1)
       (DECLARE (IGNORE DUMMY1 DUMMY))
       (MAKE-LABEL-VALUE-PAIR :-LABEL IDENTIFIER :-VALUE FEAT-TERM))

(DEFUN LABEL-VALUE-PAIR11
       (DUMMY IDENTIFIER DUMMY1)
       (DECLARE (IGNORE DUMMY1 DUMMY))
       (MAKE-LABEL-VALUE-PAIR :-LABEL IDENTIFIER))

(DEFUN FEAT-TERM13
       (IDENTIFIER DUMMY)
       (DECLARE (IGNORE DUMMY))
       (INTERN (CONCATENATE 'STRING
                            (STRING IDENTIFIER)
                            "*")))

(DEFUN FEAT-TERM14
       (IDENTIFIER DUMMY)
       (DECLARE (IGNORE DUMMY))
       (INTERN (CONCATENATE 'STRING
                            (STRING IDENTIFIER)
                            "+")))

(DEFUN FEAT-TERM15
       (CONJ)
       (MAKE-FEAT-TERM :-SLOTS CONJ))

(DEFUN CONJ16
       (DUMMY LABEL-VALUE-PAIRS DUMMY1)
       (DECLARE (IGNORE DUMMY1 DUMMY))
       LABEL-VALUE-PAIRS)

(DEFUN TYPED-CONJ17
       (IDENTIFIER DUMMY CONJ)
       (DECLARE (IGNORE DUMMY))
       (MAKE-FEAT-TERM :-SLOTS CONJ :-TYPE IDENTIFIER))

(DEFUN PRINT-FUNCTION18
       (DUMMY DUMMY1 IDENTIFIER DUMMY2)
       (DECLARE (IGNORE DUMMY2 DUMMY1 DUMMY))
       IDENTIFIER)

(DEFUN DEF-TYPE19
       (IDENTIFIER DUMMY
                   TYPED-CONJ
                   PRINT-FUNCTION
                   DUMMY1)
       (DECLARE (IGNORE DUMMY1 DUMMY))
       (CONS-DOMAIN-TYPE IDENTIFIER TYPED-CONJ PRINT-FUNCTION))

(DEFUN DEF-TYPE20
       (IDENTIFIER DUMMY CONJ PRINT-FUNCTION DUMMY1)
       (DECLARE (IGNORE DUMMY1 DUMMY))
       (CONS-DOMAIN-TYPE IDENTIFIER CONJ PRINT-FUNCTION))

