(ert-deftest test-lang-c-header-sorting ()
  "Test `citre-lang-c--get-header-at-point' and `citre-lang-c-definition-sorter'"
  (should (equal (get-*find-definitions*
		  'c-mode "buffer/buffer-header.h" "@"
		  (lambda () (backward-word 2)))
		 (get-file-contet "xref/buffer-header-a.xref")))
  (should (equal (get-*find-definitions*
		  'c-mode "buffer/buffer-header.h" "!"
		  (lambda () (backward-word 2)))
		 (get-file-contet "xref/buffer-header-b.xref")))
  )
