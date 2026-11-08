doc <- xml2::read_html("Index.html")
ids <- xml2::xml_attr(xml2::xml_find_all(doc, "//*[@id]"), "id")
stopifnot(!anyDuplicated(ids))
slides <- xml2::xml_find_all(doc, "//div[contains(concat(' ', normalize-space(@class), ' '), ' slides ')]/section")
stopifnot(length(slides) == 5L)
refs <- c(xml2::xml_attr(xml2::xml_find_all(doc, "//*[@src]"), "src"),
          xml2::xml_attr(xml2::xml_find_all(doc, "//*[@data-src]"), "data-src"),
          xml2::xml_attr(xml2::xml_find_all(doc, "//*[@href]"), "href"))
for (ref in refs) {
  if (!nzchar(ref)) next # Empty href refers to the current document.
  if (grepl("^(data:|https?:|mailto:|javascript:)", ref)) next
  if (startsWith(ref, "#")) {
    if (nchar(ref) > 1L) stopifnot(substring(ref, 2) %in% ids)
  } else {
    stopifnot(file.exists(sub("[?#].*$", "", ref)))
  }
}
images <- xml2::xml_find_all(doc, "//img")
image_refs <- xml2::xml_attr(images, "src")
image_refs[is.na(image_refs)] <- xml2::xml_attr(images, "data-src")[is.na(image_refs)]
stopifnot(length(images) >= 2L, all(startsWith(image_refs, "data:")))
stopifnot(length(xml2::xml_find_all(doc, "//a[@href='https://www.nationalarchives.gov.uk/doc/open-government-licence/version/2/']")) == 1L)
cat("Slides: five sections, unique IDs, valid references, embedded images, correct licence link.\n")
