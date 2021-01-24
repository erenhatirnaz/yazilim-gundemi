(require 'org)
(require 'ox)
(require 'ox-latex)

;; Dosya url'lerindeki '.', '..' gibi ifadelerin org-mode tarafından
;; değiştirilmemesi için bu değerin 'relative olması gerek
(setq org-link-file-path-type 'relative)

;; PDF formatında İçindekiler kısmından sonra yeni bir sayfaya geçmesi için
(setq org-latex-toc-command "\\tableofcontents \\clearpage")

;; PDF formatında diğer gündem yazılarına olan linklerin PDF linki şeklinde
;; gözükmesi için `.org' uzantıları lokal bağlantıları `.pdf' uzantısına çeviren
;; `filter-macro'.
(defun eh/convert-org-links-to-pdf-links-filter-macro (text backend info)
  "Replace .org with .pdf"
  (when (org-export-derived-backend-p backend 'latex)
    (replace-regexp-in-string "\\(yazilim-gundemi.*\\)\\.org}" "\\1.pdf}" text)))
(add-to-list 'org-export-filter-link-functions
             'eh/convert-org-links-to-pdf-links-filter-macro)

;; PDF tarafında kodları renklendirmek için yapılanlar:
(setq org-latex-listings 'minted ;; Kod bloklarını için `minted' kullan (bunun
                                 ;; için Pygments isimli python kütüphanesinin
                                 ;; kurulu olması gerek)
      org-latex-packages-alist '(("" "minted")) ;; Org latex export işleminin
                                                ;; dosyaya `minted' kütüphanesini
                                                ;; eklemesini sağlıyoruz.
      org-latex-minted-options '(("breaklines" "true") ;; Sayfaya sığmayan kod
                                                       ;; bloklarını alt satıra
                                                       ;; kesme olarak almasını
                                                       ;; sağlıyoruz.
                                 ("breakanywhere" "true"))
      org-latex-pdf-process ;; minted'in çalışabilmesi için gerekli
      '("pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
        "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
        "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"))

;; HTML tarafında kod renklendirme için `htmlize' paketi gerekli.
;; NOT: htmlize kullanırken whitespace-mod açmak HTML çıktısını bozuyor.
(setq org-html-htmlize-output-type 'css)

;; Çıktılardaki Ingilizce ifadeleri türkçeleştirmek için
;; TODO: Org-mode'un sonraki sürümlerinde Türkçe desteği de eklenecek. Kontrol et
(defun org-export-translate-to-lang (term-translations &optional lang)
  "Adds desired translations to `org-export-dictionary'.
   TERM-TRANSLATIONS is alist consisted of term you want to translate
   and its corresponding translation, first as :default then as :html and
   :utf-8. LANG is language you want to translate to."
  (dolist (term-translation term-translations)
    (let* ((term (car term-translation))
           (translation-default (nth 1 term-translation))
           (translation-html (nth 2 term-translation))
           (translation-utf-8 (nth 3 term-translation))
           (term-list (assoc term org-export-dictionary))
           (term-langs (cdr term-list)))
      (setcdr term-list (append term-langs
                                (list
                                 (list lang
                                       :default translation-default
                                       :html translation-html
                                       :utf-8 translation-utf-8)))))))

(org-export-translate-to-lang '(("Author"
                                 "Yazar")
                                ("Continued from previous page"
                                 "Önceki sayfadan devam ediyor")
                                ("Continued on next page"
                                 "Devamı sonraki sayfada")
                                ("Created"
                                 "Oluşturuldu")
                                ("Date"
                                 "Tarih")
                                ("Equation"
                                 "Eşitlik")
                                ("Figure"
                                 "Şekil")
                                ("Figure %d:"
                                 "Şekil %d:")
                                ("Table of Contents"
                                 "İçindekiler")
                                ("Table"
                                 "Tablo")
                                ("Table %d:"
                                 "Tablo %d:")
                                )
                              "tr")
