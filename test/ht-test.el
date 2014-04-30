(require 'ht)

(ert-deftest ht-test-ht ()
  (let ((test-table (ht (1 2) ("foo" (1+ 2)))))
    (should (and (member 1 (ht-keys test-table))
                 (member "foo" (ht-keys test-table))
                 (member 2 (ht-values test-table))
                 (member 3 (ht-values test-table))))))

(ert-deftest ht-test-create ()
  (should (hash-table-p (ht-create))))

(ert-deftest ht-test-set-then-get ()
  (let ((test-table (ht-create)))
    (ht-set test-table "foo" "bar")
    (should (equal (ht-get test-table "foo") "bar"))))

(ert-deftest ht-test-get-default ()
  (let ((test-table (ht-create)))
    (should (equal (ht-get test-table "foo" "default") "default"))))

(ert-deftest ht-test-update ()
  (let ((test-table (ht ("foo" 1))))
    (ht-update test-table (ht ("bar" 2)))
    (should
     (equal
      (list "bar" "foo")
      (sort (ht-keys test-table) 'string<)))))

(ert-deftest ht-test-merge ()
  (let ((table1 (ht ("foo" 1)))
        (table2 (ht ("bar" 2))))
    (should
     (equal
      (list "bar" "foo")
      (sort (ht-keys (ht-merge table1 table2)) 'string<)))))

(ert-deftest ht-test-create-non-default-test ()
  (let ((test-table (ht-create 'eq)))
    (should (equal (hash-table-test test-table) 'eq))))

(ert-deftest ht-test-remove ()
  (let ((test-table (ht-create)))
    (ht-set test-table "foo" "bar")
    (ht-remove test-table "foo")
    (should (equal (ht-get test-table "foo") nil))))

(ert-deftest ht-test-clear ()
  (let ((test-table (ht-create)))
    (ht-set test-table "foo" "bar")
    (ht-set test-table "biz" "baz")
    (ht-clear test-table)
    (should (equal (ht-items test-table) nil))))

(ert-deftest ht-test-keys ()
  (let ((test-table (ht-create)))
    (ht-set test-table "foo" "bar")
    (should (equal (ht-keys test-table) (list "foo")))))

(ert-deftest ht-test-values ()
  (let ((test-table (ht-create)))
    (ht-set test-table "foo" "bar")
    (should (equal (ht-values test-table) (list "bar")))))

(ert-deftest ht-test-items ()
  (let ((test-table (ht-create)))
    (ht-set test-table "key1" "value1")
    (should (equal (ht-items test-table) '(("key1" "value1"))))))

(ert-deftest ht-test-map ()
  (let ((total 0))
    (ht-map
     (lambda (key value) (setq total (+ total value)))
     (ht ("foo" 1) ("bar" 2)))
    (should
     (equal total 3))))

(ert-deftest ht-test-map-returns-list ()
  (should
   (equal
    (sort
     (ht-map
      (lambda (key value) (+ 1 value))
      (ht ("foo" 1) ("bar" 2)))
     '<)
    (list 2 3))))

(ert-deftest ht-test-amap ()
  (let ((total 0))
    (ht-amap
     (setq total (+ total value))
     (ht ("foo" 1) ("bar" 2)))
    (should
     (equal total 3))))

(ert-deftest ht-test-each ()
  (let ((total 0))
    (ht-each
     (lambda (key value) (setq total (+ total value)))
     (ht ("foo" 1) ("bar" 2)))
    (should
     (equal total 3))))

(ert-deftest ht-test-aeach ()
  (let ((total 0))
    (ht-aeach
     (setq total (+ total value))
     (ht ("foo" 1) ("bar" 2)))
    (should
     (equal total 3))))

(ert-deftest ht-test-aeach-nil ()
  "ht-aeach should return nil"
  (let ((total 0))
    (should
     (equal
      (ht-aeach
       (setq total (+ total value))
       (ht ("foo" 1) ("bar" 2)))
      nil))))

(ert-deftest ht-test-from-alist ()
  (let* ((alist '(("key1" . "value1")))
         (test-table (ht-from-alist alist)))
    (should (equal (ht-items test-table) '(("key1" "value1"))))))

(ert-deftest ht-test-from-alist-masked-values ()
  (let* ((alist '(("key1" . "value1") ("key1" . "value2")))
         (test-table (ht-from-alist alist)))
    (should (equal (ht-items test-table) '(("key1" "value1"))))))

(ert-deftest ht-test-from-plist ()
  (let* ((plist '("key1" "value1"))
         (test-table (ht-from-plist plist)))
    (should (equal (ht-items test-table) '(("key1" "value1"))))))

(ert-deftest ht-test-to-alist ()
  (let* ((alist '(("key1" . "value1") ("key2" . "value2")))
         (test-table (ht-from-alist alist)))
    (should (or (equal (ht-to-alist test-table) alist)
                (equal (ht-to-alist test-table) (reverse alist))))))

(ert-deftest ht-test-to-plist ()
  (let* ((test-table (ht-create)))
    (ht-set test-table "foo" "bar")
    (should (equal (ht-to-plist test-table) '("foo" "bar")))))

(ert-deftest ht-test-p ()
  "Ensure `ht-p' only returns t for hash-tables."
  (should (ht-p (ht)))
  (should-not (ht-p nil)))

(ert-deftest ht-test-contains-p ()
  (should (ht-contains-p (ht ("key" nil)) "key"))
  (should-not (ht-contains-p (ht) "key")))

(ert-deftest ht-test-size ()
  (should (= (ht-size (ht)) 0))
  (should (= (ht-size (ht ("foo" "bar"))) 1))
  (should (= (ht-size (ht ("foo" "bar")
                          ("baz" "qux"))) 2)))

(ert-deftest ht-test-empty ()
  (should (ht-empty? (ht)))
  (should-not (ht-empty? (ht ("foo" "bar"))))
  (should-not (ht-empty? (ht ("foo" "bar")
                              ("baz" "qux")))))

(ert-deftest ht-test-select ()
  (let ((results
         (ht-select
          (lambda (key value)
            (= (% value 2) 0))
          (ht
           ("foo" 1)
           ("bar" 2)
           ("baz" 3)
           ("qux" 4)))))
    (should (= (ht-size results) 2))
    (should (= (ht-get results "bar") 2))
    (should (= (ht-get results "qux") 4))))

(ert-deftest ht-test-reject ()
  (let ((results
         (ht-reject
          (lambda (key value)
            (= (% value 2) 0))
          (ht
           ("foo" 1)
           ("bar" 2)
           ("baz" 3)
           ("qux" 4)))))
    (should (= (ht-size results) 2))
    (should (= (ht-get results "foo") 1))
    (should (= (ht-get results "baz") 3))))

(ert-deftest ht-test-delete-if ()
  (let* ((table (ht
                 ("foo" 1)
                 ("bar" 2)
                 ("baz" 3)
                 ("qux" 4)))
         (results
          (ht-delete-if
           (lambda (key value)
             (= (% value 2) 0))
           table)))
    (should-not results)
    (should (= (ht-size table) 2))
    (should (= (ht-get table "foo") 1))
    (should (= (ht-get table "baz") 3))
    (should-not (ht-get table "bar"))
    (should-not (ht-get table "qux"))))

(ert-deftest ht-test-find ()
  (let* ((table (ht
                 ("baz" 3)
                 ("qux" 4)))
         (result
          (ht-find
           (lambda (key value)
             (= (% value 2) 0))
           table)))
    (should (equal result '("qux" 4)))))

(ert-deftest ht-test-find-nil ()
  (let* ((table (ht
                 ("baz" 3)
                 ("qux" 4)))
         (result
          (ht-find
           (lambda (key value)
             nil)
           table)))
    (should (equal result nil))))


(ert-deftest ht-test-swaped-items ()
  (let ((test-table 	 (ht ("key1" "value1")  )	 ))
    (should (equal (ht-swaped-items test-table) '(( "value1" "key1")))))    )

(ert-deftest ht-test-swap ()
  (let ((test-table 	 (ht ("key1" "value1")  )	 ))
    (should (equal (ht-to-alist (ht-swap test-table)) '(( "value1" . "key1")))))    )

(ert-deftest ht-test-valueds ()
  (let ((test-table 
	 (ht ("key1" "value1")  ("key2" "value2")  ("key3" "value2"))	 	 ))
    (should (equal (ht-valueds test-table "value2")  '( "key3" "key2")))    ))

(ert-deftest ht-test-valued ()
  (let ((test-table 
	 (ht ("key1" "value1")  ("key2" "value2") )	 	 ))
    (should (equal (ht-valued test-table "value2")  "key2"))    ))

(ert-deftest ht-test-gen-key ()
  (let ((test-table (ht-create)))    
    (should-not (ht-get test-table (ht-gen-key test-table )))    ))

(ert-deftest ht-test-store-value ()
  (let* (
	 (key1 "key1")
	 (value1 "value1")
	 (test-table (ht (key1 value1)))
	 (value2 "value2")
	 (key2 (ht-store-value! test-table value2))
	 )
    (should (equal (ht-to-alist test-table) (list  (cons key2 value2)  (cons key1 value1) )))
    (should (equal (ht-get test-table key2 ) value2))
    (should (equal (ht-valued test-table value2 ) key2))    
    (should (equal (ht-valued test-table value1 ) key1))    
    (let (  (key3 (ht-store-value! test-table value1))  )
      (should (equal key3 key1)) 
      (should (equal (ht-to-alist test-table) (list  (cons key2 value2)  (cons key1 value1) )))
      (let  ((key4 (ht-store-value! test-table value2)))
      (should (equal key4 key4)) 
      (should (equal (ht-to-alist test-table) (list  (cons key2 value2)  (cons key1 value1) )))
    ))))

(ert-deftest ht-test-gen-str-key ()
  (let ((test-table (ht-create)))    
    (should-not (ht-get test-table (ht-gen-str-key test-table "value1" )))    ))

(ert-deftest ht-test-store-str-value ()
  (let* (
	 (key1 "key1")
	 (value1 "value1")
	 (test-table (ht (key1 value1)))
	 (value2 "value2")
	 (key2 (ht-store-str-value! test-table value2))
	 )
    (should (equal (length value2) (length key2)))
    (should (equal (ht-to-alist test-table) (list  (cons key2 value2)  (cons key1 value1) )))
    (should (equal (ht-get test-table key2 ) value2))
    (should (equal (ht-valued test-table value2 ) key2))    
    (should (equal (ht-valued test-table value1 ) key1))    
    (let (  (key3 (ht-store-str-value! test-table value1))  )
      (should (equal key3 key1)) 
      (should (equal (ht-to-alist test-table) (list  (cons key2 value2)  (cons key1 value1) )))
      (let  ((key4 (ht-store-str-value! test-table value2)))
    	(should (equal key4 key4)) 
    	(should (equal (ht-to-alist test-table) (list  (cons key2 value2)  (cons key1 value1) )))
    	)
      )
    ))


 

(defun ht-run-tests ()
  (interactive)
  (ert-run-tests-interactively "ht-test-"))
